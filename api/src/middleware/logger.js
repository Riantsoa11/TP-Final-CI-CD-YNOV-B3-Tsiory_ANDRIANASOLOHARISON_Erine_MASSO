const crypto = require("crypto");
const log = require("../utils/log");

module.exports = function requestLogger(req, res, next) {
  req.requestId = crypto.randomBytes(8).toString("hex");
  res.setHeader("X-Request-Id", req.requestId);
  const startedAt = Date.now();

  res.on("finish", () => {
    const entry = {
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      duration_ms: Date.now() - startedAt,
      request_id: req.requestId,
    };
    if (res.statusCode >= 500) {
      log.error("request", entry);
    } else if (res.statusCode >= 400) {
      log.warn("request", entry);
    } else {
      log.info("request", entry);
    }
  });

  next();
};
