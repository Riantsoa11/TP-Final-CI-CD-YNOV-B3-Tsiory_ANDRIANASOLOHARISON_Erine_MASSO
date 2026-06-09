const request = require("supertest");
const app = require("../src/app");

describe("GET /products", () => {
  test("returns 200 with products array from database", async () => {
    const res = await request(app).get("/products");
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("source", "database");
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  test("each product has id, name, description, price_cents", async () => {
    const res = await request(app).get("/products");
    expect(res.status).toBe(200);
    const product = res.body.data[0];
    expect(product).toHaveProperty("id");
    expect(product).toHaveProperty("name");
    expect(product).toHaveProperty("description");
    expect(product).toHaveProperty("price_cents");
    expect(typeof product.price_cents).toBe("number");
    expect(product.price_cents).toBeGreaterThan(0);
  });
});

describe("Error handling", () => {
  test("GET /unknown returns 404", async () => {
    const res = await request(app).get("/unknown-route-xyz");
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty("error");
  });

  test("GET /health returns api and database status", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBeLessThan(600);
    expect(res.body).toHaveProperty("checks");
    expect(res.body.checks).toHaveProperty("api", "ok");
  });
});
