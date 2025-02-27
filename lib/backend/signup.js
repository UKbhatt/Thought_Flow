const { supabase } = require("./service/supabase");

const signup = async (req, res) => {

    const { email, password, Display_name } = req.body;
    if (!email || !password || !Display_name) {
        return res.status(400).json({ error: "Email and password are required" });
    }

    const { data, error } =
        await supabase.auth.signUp({ email, password });

    if (error) {
        console.log("Error:" + error.message);
        return res.status(400).json({ error: error.message });
    }

    const user_id = data.user.id;

    const { error: ProfileError } =
        await supabase.from("profiles").insert([{ id: user_id, display_name: Display_name }]);

    if (ProfileError) {
        console.log("ProfileError:" + ProfileError.message);
        return res.status(400).json({ error: ProfileError.message });
    }

    console.log("success");
    res.status(200).json({ message: "Signup Successful!!", user: data.user });

};



module.exports = signup;
