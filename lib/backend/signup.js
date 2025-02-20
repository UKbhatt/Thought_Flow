const { supabase } = require("./supabase");

const signup = async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required" });
    }

    const { user, error } = await supabase.auth.signUp({ email, password });

    if (error) {
        console.log(error.message);

        return res.status(400).json({ error: error.message });
    }

    console.log("success");
    res.status(200).json({ message: "User signed up successfully!", user });
};


module.exports = signup; 
