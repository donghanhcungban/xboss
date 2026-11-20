import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { test } from "node:test";

test("bản skill Codex giữ đúng byte nguồn và hash của khung X-Templates", () => {
  const manifest: { codex_files: Record<string, string> } = JSON.parse(
    readFileSync(".xtemplates/manifest.json", "utf8"),
  );
  const skills = Object.entries(manifest.codex_files).filter(([file]) =>
    /^\.agents\/skills\/[\w-]+\/SKILL\.md$/.test(file),
  );
  assert.ok(skills.some(([file]) => file === ".agents/skills/factory/SKILL.md"));
  for (const [file, hash] of skills) {
    const mirror = readFileSync(file);
    assert.equal("sha256:" + createHash("sha256").update(mirror).digest("hex"), hash, file);
    assert.deepEqual(mirror, readFileSync(file.replace(".agents/", ".claude/")), file);
  }
});
