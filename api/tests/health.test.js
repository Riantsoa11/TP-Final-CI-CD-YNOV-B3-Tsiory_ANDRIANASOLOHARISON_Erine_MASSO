const request = require("supertest");
const app = require("../src/app");

describe("GET /", () => {
  test("returns API name, version and endpoints", async () => {
    const res = await request(app).get("/");
    expect(res.status).toBe(200);
    expect(res.body.name).toBe("ShopLite API");
    expect(res.body).toHaveProperty("version");
    expect(res.body).toHaveProperty("endpoints");
    expect(res.body.endpoints).toContain("/ready");
  });
});

describe("GET /health", () => {
  test("returns status, version, checks and timestamp", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBeLessThan(600);
    expect(res.body).toHaveProperty("status");
    expect(res.body).toHaveProperty("service", "shoplite-api");
    expect(res.body).toHaveProperty("version");
    expect(res.body).toHaveProperty("checks");
    expect(res.body).toHaveProperty("timestamp");
    expect(res.body.checks).toHaveProperty("api", "ok");
  });
});

describe("GET /ready", () => {
  test("returns ready field and timestamp", async () => {
    const res = await request(app).get("/ready");
    expect(res.status).toBeLessThan(600);
    expect(res.body).toHaveProperty("ready");
    expect(res.body).toHaveProperty("service", "shoplite-api");
    expect(res.body).toHaveProperty("timestamp");
  });
});

describe("Error handling", () => {
  test("GET /nonexistent returns 404 with error field", async () => {
    const res = await request(app).get("/nonexistent-route");
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty("error");
  });

  test("response includes X-Request-Id header", async () => {
    const res = await request(app).get("/");
    expect(res.headers).toHaveProperty("x-request-id");
    expect(res.headers["x-request-id"]).toHaveLength(16);
  });
});
