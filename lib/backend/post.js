const express = require("express");
const multer = require("multer");
const path = require("path");
const { uploadImageToSupabase } = require("./service/storage").uploadImageToSupabase;
const { supabase } = require("./service/supabase");
const { v4: uuid4 } = require('uuid');

const router = express.Router();

const upload = multer({
    storage: multer.diskStorage({
        destination: "uploads/",
        filename: (req, file, cb) => {
            cb(null, Date.now() + path.extname(file.originalname));
        }
    })
});

router.post("/upload", upload.single("post_image"), async (req, res) => {
    try {
        const { userId, post_text, post_title, visible } = req.body;
        const file = req.file;

        if (!userId || !post_text || !post_title || !file) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        const filePath = await uploadImageToSupabase(file, userId);

        const { data: profile, error: profileError } = await supabase
            .from("profiles")
            .select("display_name")
            .eq("id", userId)
            .single();

        if (profileError || !profile) {
            console.log("Profile Fetch Error:", profileError);
            throw new Error("Failed to fetch user profile");
        }

        const displayName = profile.display_name;

        const { data: postData, error: insertError } = await supabase
            .from("posts")
            .insert([
                {
                    id: uuid4(),
                    author_id: userId,
                    image_url: filePath,
                    content: post_text,
                    title: post_title,
                    visibility: visible
                }
            ])
            .select();

        if (insertError) {
            console.log("Insert Error:", insertError);
            throw new Error(insertError.message);
        }

        const postId = postData[0].id;

        const { error: likeError } = await supabase
            .from("likes")
            .insert([
                {
                    id: uuid4(),
                    post_id: postId,
                    user_id: userId
                }
            ]);

        if (likeError) {
            console.log("Like Insert Error:", likeError);
            throw new Error(likeError.message);
        }

        postData[0].display_name = displayName;

        console.log("Successfully uploaded post and inserted into likes table");

        const { data: likeCount, error: likecountError } =
            await supabase.from('likes').select('post_id', { count: 'exact' }).eq('post_id', postId);

        if (likecountError) {
            console.log("Like Insert Error:", likecountError);
            throw new Error(likecountError.message);
        }

        console.log("like count is " + likeCount);
        postData[0].likeCount = likeCount[0].count;

        res.status(201).json({
            message: "Post uploaded successfully and auto-liked",
            post: postData[0]
        });

    } catch (error) {
        console.error("Upload Error:", error.message);
        res.status(500).json({ error: error.message });
    }
});

router.post("/getPosts", async (req, res) => {
    try {
        const { userid } = req.body;

        const { data: posts, error: fetchError } = await supabase.from("posts").select("*");

        if (fetchError) {
            console.log("Fetch Error:", fetchError);
            throw new Error(fetchError.message);
        }

        if (!posts || posts.length === 0) {
            return res.status(200).json({ message: "No posts found", data: [] });
        }

        const authorIds = [...new Set(posts.map(post => post.author_id))];

        const { data: users, error: userError } = await supabase
            .from("profiles")
            .select("id, display_name")
            .in("id", authorIds);

        if (userError) {
            console.log("User Fetch Error:", userError);
            throw new Error(userError.message);
        }

        const userMap = users.reduce((acc, user) => {
            acc[user.id] = user.display_name;
            return acc;
        }, {});

        const likeCounts = {};
        const isLikedMap = {}; 
        for (const post of posts) {
            const { count, error: likeError } = await supabase
                .from("likes")
                .select("*", { count: "exact", head: true })
                .eq("post_id", post.id);

            if (likeError) {
                console.log(`Like Fetch Error for Post ID ${post.id}:`, likeError);
                throw new Error(likeError.message);
            }

            likeCounts[post.id] = count || 0;

            if (userid) {
                const { data: likedData, error: isLikedError } = await supabase
                    .from("likes")
                    .select("id")
                    .eq("post_id", post.id)
                    .eq("user_id", userid)
                    .single();

                if (isLikedError && isLikedError.code !== "PGRST116") {
                    console.log(`Error fetching isLiked for post ${post.id}:`, isLikedError);
                    throw new Error(isLikedError.message);
                }

                isLikedMap[post.id] = !!likedData; 
            }
        }

        const postsWithDetails = posts.map((post) => ({
            ...post,
            display_name: userMap[post.author_id] || "Unknown",
            like_count: likeCounts[post.id] || 0,
            is_liked: isLikedMap[post.id] || false,
        }));
        res.status(200).json({
            message: "Successfully fetched all posts",
            data: postsWithDetails,
        });

    } catch (error) {
        console.error("Fetch Error:", error.message);
        res.status(500).json({ error: error.message });
    }
});

router.post("/like", async (req, res) => {
    try {
        const { post_id, user_id } = req.body;
        if (!post_id || !user_id) {
            return res.status(400).json({ message: "post_id and user_id are required" });
        }

        const { data: existingLike, error: fetchError } = await supabase
            .from("likes")
            .select("*")
            .eq("post_id", post_id)
            .eq("user_id", user_id)
            .single();

        if (fetchError && fetchError.code !== "PGRST116") {
            return res.status(500).json({ error: fetchError.message });
        }

        if (existingLike) {
            const { error: deleteError } = await supabase
                .from("likes")
                .delete()
                .eq("post_id", post_id)
                .eq("user_id", user_id);

            if (deleteError) {
                return res.status(500).json({ error: deleteError.message });
            }
        } else {
         
            const { error: insertError } = await supabase
                .from("likes")
                .insert([{ id: uuidv4(), post_id, user_id }]);

            if (insertError) {
                return res.status(500).json({ error: insertError.message });
            }
        }

        const { data: likeCountData, error: countError } = await supabase
            .from("likes")
            .select("*", { count: "exact" })
            .eq("post_id", post_id);

        if (countError) {
            return res.status(500).json({ error: countError.message });
        }

        return res.status(200).json({
            message: existingLike ? "Post unliked successfully" : "Post liked successfully",
            isLiked: !existingLike,
            likeCount: likeCountData.length, 
        });

    } catch (error) {
        console.error("Error liking post:", error);
        return res.status(500).json({ error: error.message });
    }
});


module.exports = router;
