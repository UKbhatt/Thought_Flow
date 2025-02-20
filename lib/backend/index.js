const express = require("express");
const dotenv = require("dotenv");
const signup = require("./signup").default || require("./signup");
const login = require("./login").default || require("./login");


dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());


app.post("/signup", signup);
app.post("/login", login);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
