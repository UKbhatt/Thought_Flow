const fs = require("fs");
const { supabase } = require("./supabase");
const { v4: uuid4 } = require('uuid');

const uploadImageToSupabase = async (file, userId) => {

    const fileBuffer = fs.readFileSync(file.path);

    const { data, error } = await supabase.storage
        .from(process.env.bucket_name)
        .upload(userId + "/" + uuid4() + ".jpg", fileBuffer, {
            contentType: file.mimetype,
        });

    if (data) {
        const { data: publicUrlData } = supabase.storage
            .from(process.env.BUCKET_NAME)
            .getPublicUrl(data.path);

        const publicUrl = publicUrlData.publicUrl;
        fs.unlinkSync(file.path);

        return publicUrl;

    }


    if (error) {
        console.log("Image uploading error")
        throw new Error(error.message);
    }

};

module.exports = { uploadImageToSupabase };