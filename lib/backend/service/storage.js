const fs = require("fs");
const path = require("path");
const { supabase } = require("../supabase");

// Function to upload image to Supabase
const uploadImageToSupabase = async (file, userId) => {
    const filePath = `users/${userId}/${file.filename}`;
    const fileBuffer = fs.readFileSync(file.path);

    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
        .from(process.env.posts_image)
        .upload(filePath, fileBuffer, {
            contentType: file.mimetype,
        });

    // Delete local file after upload
    fs.unlinkSync(file.path);

    if (error) throw new Error(error.message);

    return filePath; // Return stored path (not public URL)
};

// Function to get the public URL (if needed)
const getPublicImageUrl = (filePath) => {
    return supabase.storage.from(process.env.posts_image).getPublicUrl(filePath).publicUrl;
};

module.exports = { uploadImageToSupabase, getPublicImageUrl };
