const { supabase } = require("./supabase");

const login = async (req, res) => {
    // console.log(req.body);
    const { email, password } = req.body;

    if (!email || !password) {
        console.log("unfiled parameters");
        return res.status(400).json({ error: "Email and password are required" });
    }

    const {data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
    });

    if (error) {
        return res.status(400).json({ error: error.message });
    }
    const user = data.user;
    const session = data.session;
    console.log("successful login!!");
    // console.log(user, session);
    res.status(200).json({  user, session });
};

const logout = async (req, res) => {
    const { error } = await supabase.auth.signOut();

    if (error) {
        return res.status(400).json({ error: error.message });
    }
    res.status(200).json({ message: "Logout successful!!" });
}

module.exports = login, logout;
