const express = require("express");
const multer = require("multer");
const path = require("path");
const { uploadImageToSupabase, getPublicImageUrl } = require("./service/storage");
const { supabase } = require("./supabase");

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

        const filePath = await uploadImageToSupabase(file, id);

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

        if (insertError){
            console.log("Insert Error");
            throw new Error(insertError.message)
        };

        console.log("✅ Successfully uploaded");

        res.status(201).json({
            message: "Post uploaded successfully", 
        });

    } catch (error) {
        console.error("❌ Upload Error:", error.message);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
