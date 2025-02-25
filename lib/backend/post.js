const express = require("express");
const multer = require("multer");
const path = require("path");
const { uploadImageToSupabase, getPublicImageUrl } = require("./service/storage");
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
        const { id, post_text, post_title, visible } = req.body;
        const file = req.file;

        if (!id || !post_text || !post_title || !file) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        // Upload image to Supabase storage
        const filePath = await uploadImageToSupabase(file, id);

        // Insert post data into Supabase
        const { error: insertError } = await supabase
            .from("posts")
            .insert([
                {
                    author_id: id,
                    image_url: filePath,
                    content: post_text,
                    title: post_title,
                    visibility: visible
                }
            ]);

        if (insertError) {
            console.log("Insert Error:", insertError);
            throw new Error(insertError.message);
        }

        console.log("Successfully uploaded");
        res.status(201).json({ message: "Post uploaded successfully" });

    } catch (error) {
        console.error("Upload Error:", error.message);
        res.status(500).json({ error: error.message });
    }
});

router.get("/getPosts", async (req, res) => {
    try {
        const { data: posts, error: fetchError } = await supabase.from("posts").select();

        if (fetchError) {
            console.log("Fetch Error");
            throw new Error(fetchError.message);
        }

        if (!posts) {
            return res.status(200).json({ message: "No posts found", data: [] });
        }

        const authorIds = [...new Set(posts.map((post) => post.author_id))];

        const { data: users, error: userError } = await supabase
            .from("profiles")
            .select("id, display_name")
            .in("id", authorIds);

        if (userError) {
            console.log("User Error");
            throw new Error(userError.message);
        }

        const userMap = users.reduce((acc, user) => {
            acc[user.id] = user.display_name;
            return acc;
        }, {});

        const postsWithUsernames = posts.map((post) => ({
            ...post,
            display_name: userMap[post.author_id] || "Unknown",
        }));

        res.status(200).json({
            message: "Successfully fetched all posts",
            data: postsWithUsernames,
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

        // Check if the user already liked the post
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
            // Unlike the post (delete the like)
            const { error: deleteError } = await supabase
                .from("likes")
                .delete()
                .eq("post_id", post_id)
                .eq("user_id", user_id);

            if (deleteError) {
                return res.status(500).json({ error: deleteError.message });
            }

            return res.status(200).json({ message: "Post unliked successfully" });
        }

        // Insert new like
        const { error: insertError } = await supabase
            .from("likes")
            .insert([{
                id: uuid4(),
                post_id, user_id
            }]);

        if (insertError) {
            return res.status(500).json({ error: insertError.message });
        }

        return res.status(200).json({ message: "Post liked successfully" });
    } catch (error) {
        console.error("Error liking post:", error);
        return res.status(500).json({ error: error.message });
    }
});


module.exports = router;
