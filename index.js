const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");

const app = express();
const port = process.env.PORT || 3000;

const uploadsPath = path.join(__dirname, "uploads/");
const passwords = {};
const allowedFiletypes = /gz/;

const upload = multer({
  storage: multer.diskStorage({
    destination: "uploads/",
    filename: function (req, file, cb) {
      // Simple storage by filename
      const filePath = path.join(uploadsPath, file.originalname);
      req.fileExists = fs.existsSync(filePath) ? true : false;
      cb(null, file.originalname);
    },
  }),
  fileFilter: function (req, file, cb) {
    // Filter extension
    if (allowedFiletypes.test(path.extname(file.originalname).toLowerCase())) {
      cb(null, true);
    } else {
      req.notGz = true;
      cb(null, false);
    }
  },
});

app.listen(port, () => {
  console.log("Example app listening on port ", port);
});

app.get("/", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/download/:filename", (req, res) => {
  const filename = req.params.filename;
  const filePath = path.join(uploadsPath, filename);

  // Check if file exists
  if (!fs.existsSync(filePath)) {
    res.status(404).json({ status: "file not found" });
    return;
  }
  // Check password
  if (passwords[filename] != req.query.password) {
    res.status(401).json({ status: "incorrect password" });
    return;
  } else {
    res.sendFile(filePath);
  }
});

app.post("/upload", upload.single("file"), (req, res) => {
  //check if file exists (either by extension incompatibility or error)
  if (!req.file && req.notGz) {
    res.status(415).json({ status: "incompatible file format" });
    return;
  } else if (!req.file) {
    res.status(400).json({ status: "file not received" });
    return;
  }

  const message = req.fileExists ? "file overwritten" : "file created";
  const havePassword = req.body.password ? "true" : "false";
  const password = req.body.password;
  passwords[req.file.filename] = password;

  res.json({ status: "ok", message: message, password: havePassword });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "unexpected error: " + err.message });
});
