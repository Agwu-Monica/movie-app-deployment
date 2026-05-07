const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());

const movies = [
  { id: 1, title: "Avengers" },
  { id: 2, title: "Batman" },
  { id: 3, title: "Spider-Man" }
];

app.get("/", (req, res) => {
  res.send("Backend is running");
});

app.get("/api/v1/movies", (req, res) => {
  res.json(movies);
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});