const log = require("../src/utils/log");

describe("utils/log", () => {
  let logSpy;
  let errorSpy;

  beforeEach(() => {
    logSpy = jest.spyOn(console, "log").mockImplementation(() => {});
    errorSpy = jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterEach(() => {
    logSpy.mockRestore();
    errorSpy.mockRestore();
  });

  test("info() écrit sur console.log", () => {
    log.info("test message");
    expect(logSpy).toHaveBeenCalled();
  });

  test("warn() écrit sur console.log", () => {
    log.warn("test warning");
    expect(logSpy).toHaveBeenCalled();
  });

  test("error() écrit sur console.error", () => {
    log.error("test error");
    expect(errorSpy).toHaveBeenCalled();
  });

  test("fatal() écrit sur console.error", () => {
    log.fatal("test fatal");
    expect(errorSpy).toHaveBeenCalled();
  });

  test("debug() est ignoré au niveau info par défaut", () => {
    log.debug("test debug");
    expect(logSpy).not.toHaveBeenCalled();
  });

  test("sanitize masque les champs sensibles (password, token...)", () => {
    log.info("login", { password: "secret123", user: "erine" });
    const output = JSON.parse(logSpy.mock.calls[0][0]);
    expect(output.password).toBe("***");
    expect(output.user).toBe("erine");
  });
});
