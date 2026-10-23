import { defineConfig, devices } from "@playwright/test";

const ci = !!process.env.CI;
const port = Number(process.env.E2E_PORT ?? 3000);
const url = `http://localhost:${port}`;

export default defineConfig({
  testDir: "e2e",
  forbidOnly: ci,
  retries: ci ? 1 : 0,
  reporter: ci ? [["html", { open: "never" }], ["list"]] : "list",
  use: { baseURL: url, trace: "retain-on-failure" },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    // CI builds first and serves the production build; locally the dev server is enough.
    command: `next ${ci ? "start" : "dev"} --port ${port}`,
    url: `${url}/api/health`,
    reuseExistingServer: !ci,
  },
});
