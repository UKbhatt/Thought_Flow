const express = require("express");
const dotenv = require("dotenv");
const signup = require("./signup");
const login  = require("./login");
const profileImageRoutes = require("./profileImage.js");
const postsRoutes = require("./post");
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json());
app.post("/signup", signup);
app.use("/profile", profileImageRoutes);
app.use("/post", postsRoutes);
app.post("/login", login);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
