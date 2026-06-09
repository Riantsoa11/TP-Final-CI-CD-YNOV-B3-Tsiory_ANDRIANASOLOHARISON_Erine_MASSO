const LEVELS = { debug: 0, info: 1, warn: 2, error: 3, fatal: 4 };
const CURRENT = LEVELS[process.env.LOG_LEVEL?.toLowerCase()] ?? LEVELS.info;
const SENSITIVE = /password|secret|token|key|authorization|database_url|pwd/i;

function sanitize(obj) {
  if (typeof obj !== "object" || obj === null) return obj;
  if (Array.isArray(obj)) return obj.map(sanitize);
  return Object.fromEntries(
    Object.entries(obj).map(([k, v]) => [
      k,
      SENSITIVE.test(k) ? "***" : sanitize(v),
    ]),
  );
}

function write(level, message, extra = {}) {
  if (LEVELS[level] < CURRENT) return;
  const entry = {
    level,
    message,
    ...sanitize(extra),
    timestamp: new Date().toISOString(),
  };
  const out =
    level === "error" || level === "fatal" ? console.error : console.log;
  out(JSON.stringify(entry));
}

module.exports = {
  debug: (msg, extra) => write("debug", msg, extra),
  info: (msg, extra) => write("info", msg, extra),
  warn: (msg, extra) => write("warn", msg, extra),
  error: (msg, extra) => write("error", msg, extra),
  fatal: (msg, extra) => write("fatal", msg, extra),
};
