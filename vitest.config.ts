import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: [
      { test: { name: "unit", include: ["lib/**/*.test.ts", "app/**/*.test.ts"] } },
      { test: { name: "int", include: ["tests/int/**/*.test.ts"] } },
    ],
  },
});
