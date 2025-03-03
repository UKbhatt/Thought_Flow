const express = require("express");
const { supabase } = require("./service/supabase");
const { uploadProfileImageToSupabase } = require("./service/storage").uploadProfileImageToSupabase;
const multer = require("multer");
const path = require("path");

const router = express.Router();

const upload = multer({
    storage: multer.diskStorage({
        destination: "uploads/",
        filename: (_req, file, cb) => {
            cb(null, Date.now() + path.extname(file.originalname));
        }
    })
});

router.post("/PostImage", upload.single("image"), async (req, res) => {
    const { user_id } = req.body;
    const file = req.file;

    if (!user_id || !file) {
        return res.status(400).json({ error: "UserId and Image file are required" });
    }

    try {
        const filePath = await uploadProfileImageToSupabase(file, user_id);

        const { data: ProfileData, error: ProfileError } =
            await supabase.from("profiles")
                .update({ profile_image: filePath })
                .eq("id", user_id)
                .select();

        if (ProfileError) {
            console.error("ProfileError:", ProfileError);
            return res.status(400).json({ error: ProfileError.message });
        }

        console.log("Profile image updated successfully:", ProfileData);
        return res.status(200).json({ message: "Profile image updated successfully", data: ProfileData });

    } catch (error) {
        console.error("Upload Error:", error);
        return res.status(500).json({ error: "Failed to upload image" });
    }
});

router.post("/GetImage", async (req, res) => {
    const { user_id } = req.body;

    if (!user_id) {
        return res.status(400).json({ error: "UserId is missing" });
    }

    try {
        const { data: ProfileImage, error: ProfileErrorImg } =
            await supabase.from("profiles").select("profile_image").eq("id", user_id).single();

        if (ProfileErrorImg) {
            console.error("ProfileErrorImg:", ProfileErrorImg);
            return res.status(400).json({ error: ProfileErrorImg.message });
        }

        if (!ProfileImage) {
            return res.status(404).json({ error: "Profile image not found" });
        }

        console.log("Successfully fetched Profile Image:", ProfileImage);
        return res.status(200).json({ message: "Profile image fetched successfully", data: ProfileImage });

    } catch (error) {
        console.error("Failed to fetch image", error);
        return res.status(500).json({ error: "Failed to fetch image" });
    }
});

module.exports = router;
