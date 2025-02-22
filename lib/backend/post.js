const express = require("express");
const multer = require("multer");
const path = require("path");
const { uploadImageToSupabase, getPublicImageUrl } = require("./service/storage");
const { supabase } = require("./supabase");

const router = express.Router();

// Configure multer for temporary local storage
const upload = multer({
    storage: multer.diskStorage({
        destination: "uploads/",
        filename: (req, file, cb) => {
            cb(null, Date.now() + path.extname(file.originalname));
        }
    })
});

// Upload post with image
router.post("/upload", upload.single("post_image"), async (req, res) => {
    try {
        const { id, post_text, post_title, visible } = req.body;
        const file = req.file;

        if (!id || !post_text || !post_title || !file) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        // Upload image to Supabase
        const filePath = await uploadImageToSupabase(file, id);

        // Insert post data into Supabase database
        const { error: insertError } = await supabase
            .from("posts")
            .insert([
                {
                    author_id: id,
                    image: filePath, // Store path, not URL
                    content: post_text,
                    title: post_title,
                    visibility: visible
                }
            ]);

        if (insertError) throw new Error(insertError.message);
        console.error("Successfully uploaded");
        res.status(201).json({
            message: "Post uploaded successfully",
            image_path: filePath,
            public_url: getPublicImageUrl(filePath)
        });

    } catch (error) {
        console.error("Upload Error:", error.message);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
