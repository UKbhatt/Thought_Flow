const express = require("express");
const dotenv = require("dotenv");
const signup = require("./signup").default || require("./signup");
const post = require("./post").default || require("./post");
const login = require("./login").login || require("./login");
const logout = require("./login").logout || require("./login");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json());

app.post("/signup", signup);
app.post("/post", post);
app.post("/logout", logout);
app.post("/login", login);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
