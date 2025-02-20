const { supabase } = require("./supabase");

const login = async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required" });
    }

    const { user, session, error } = await supabase.auth.signInWithPassword({
        email,
        password,
    });

    if (error) {
        return res.status(400).json({ error: error.message });
    }

    res.status(200).json({ message: "Login successful!!", user, session });
};

const logout = async (req, res){
    const { error } = await supabase.auth.signOut();
}

module.exports = login,logout;
