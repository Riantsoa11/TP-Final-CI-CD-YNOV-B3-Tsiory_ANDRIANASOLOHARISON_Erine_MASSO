const express = require("express");
const db = require("../db");

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    await db.query("SELECT 1");
    res.json({
      ready: true,
      service: "shoplite-api",
      timestamp: new Date().toISOString(),
    });
  } catch (_err) {
    res.status(503).json({
      ready: false,
      service: "shoplite-api",
      error: "database not ready",
      timestamp: new Date().toISOString(),
    });
  }
});

module.exports = router;
