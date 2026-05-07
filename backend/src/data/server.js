const express = require("express");
const cors = require("cors");
const movies = require("./data/movies");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Movie Backend is Running 🚀");
});

app.get("/api/v1/movies", (req, res) => {
  res.json({
    success: true,
    data: movies
  });
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});