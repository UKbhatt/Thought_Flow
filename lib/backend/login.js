const { supabase } = require("./service/supabase");

const login = async (req, res) => {
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
        console.log("Unsuccessful login!!");
        return res.status(400).json({ error: error.message });
    }
    const user = data.user;
    const session = data.session;
    console.log("successful login!!");
   
    res.status(200).json({  user, session });
};



module.exports = login;
