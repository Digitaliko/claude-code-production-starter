import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, describe, expect, it } from "vitest";

// Runs .husky/commit-msg the way git does: sh with the message file as $1.
const dir = mkdtempSync(join(tmpdir(), "commit-msg-"));
afterAll(() => rmSync(dir, { recursive: true, force: true }));

function hook(message: string): number | null {
  const file = join(dir, "COMMIT_EDITMSG");
  writeFileSync(file, `${message}\n`);
  return spawnSync("sh", [".husky/commit-msg", file], { encoding: "utf8" }).status;
}

const types = ["feat", "fix", "refactor", "chore", "docs", "test", "ci", "perf", "build", "style", "revert"];

describe(".husky/commit-msg", () => {
  it.each(types)("accepts %s with and without a scope", (type) => {
    expect(hook(`${type}: summary`)).toBe(0);
    expect(hook(`${type}(scope): summary`)).toBe(0);
    expect(hook(`${type}!: breaking summary`)).toBe(0);
  });

  it.each([
    "build(deps): bump actions/checkout from 5 to 7",
    "build(deps-dev): bump @types/node from 22.20.5 to 26.6.5",
    "build(deps): bump the minor-and-patch group across 1 directory with 6 updates",
  ])("accepts the dependabot message %j", (message) => {
    expect(hook(message)).toBe(0);
  });

  it.each(["Merge branch 'main' into feat/x", 'Revert "feat: x"', "fixup! feat: x", "squash! feat: x"])(
    "passes %j through",
    (message) => {
      expect(hook(message)).toBe(0);
    },
  );

  it.each(["nope", "feature: x", "fix:x", "Fix: x", "fix(Scope): x", "fix: "])("rejects %j", (message) => {
    expect(hook(message)).toBe(1);
  });
});
