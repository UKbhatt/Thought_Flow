const { supabase } = require("./supabase");

const post = async (req, res) => {
    const { id, post_text, post_image, post_title } = req.body;

    if (!text || !title)
        return res.status(400).json({ error: "Text content cannot be empty" });

    const {error } = await supabase.from("posts").insert({
        author_id: id, image: post_image, content: post_text, title: post_title
    });

    if (error)
        return res.status(400).json({ error: error.message });

    res.status(201).json({ message: "Uploading complete"})
}

module.exports = post;