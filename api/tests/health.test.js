const request = require("supertest");
const app = require("../src/app");

describe("GET /", () => {
  test("returns API name and version", async () => {
    const res = await request(app).get("/");
    expect(res.status).toBe(200);
    expect(res.body.name).toBe("ShopLite API");
    expect(res.body).toHaveProperty("version");
    expect(res.body).toHaveProperty("endpoints");
  });
});

describe("GET /health", () => {
  test("returns health status with checks and timestamp", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBeLessThan(600);
    expect(res.body).toHaveProperty("status");
    expect(res.body).toHaveProperty("service", "shoplite-api");
    expect(res.body).toHaveProperty("checks");
    expect(res.body).toHaveProperty("timestamp");
    expect(res.body.checks).toHaveProperty("api", "ok");
  });
});

describe("Error handling", () => {
  test("GET /nonexistent returns 404 with error field", async () => {
    const res = await request(app).get("/nonexistent-route");
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty("error");
  });
});
