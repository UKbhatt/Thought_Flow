const { supabase } = require("./supabase");

const post = async (req, res) => {
    const { id, text, image, title } = req.body;

    if (!text || !title)
        return res.status(400).json({ error: "Text content can't be emptpy" });
    
}

module.exports = post;