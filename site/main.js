const express = require("express");
const { port, oauh2_url } = require("./config.json");

const app = express();

app.set("view engine", "ejs");
app.set("views", __dirname+"/views")

app.get('/', (request, response, next) => {
	response.render("index", {"oauth2_url": oauh2_url})
});

app.listen(port, () => console.log(`App listening at http://localhost:${port}`));