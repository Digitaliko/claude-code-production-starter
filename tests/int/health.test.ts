import { afterEach, describe, expect, it } from "vitest";
import { GET } from "../../app/api/health/route";

describe("GET /api/health", () => {
  afterEach(() => {
    delete process.env.APP_ENV;
  });

  it("answers ok with the current environment", async () => {
    process.env.APP_ENV = "ci";
    const res = GET();
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true, env: "ci" });
  });
});
