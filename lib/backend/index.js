const express = require("express");
const dotenv = require("dotenv");
const signup = require("./signup").default || require("./signup");
const login = require("./login").login || require("./login");
const logout = require("./login").logout || require("./login");
const postsRoutes = require("./post");
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json());
app.post("/signup", signup);
app.use("/post", postsRoutes);

app.post("/logout", logout);
app.post("/login", login);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`)

});

