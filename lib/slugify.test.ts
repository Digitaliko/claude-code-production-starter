import { describe, expect, it } from "vitest";
import { slugify } from "./slugify";

describe("slugify", () => {
  it("lowercases and joins words with hyphens", () => {
    expect(slugify("Hello, World!")).toBe("hello-world");
  });

  it("strips accents", () => {
    expect(slugify("Crème brûlée")).toBe("creme-brulee");
  });

  it("returns an empty string for punctuation only", () => {
    expect(slugify("!!!")).toBe("");
  });
});
