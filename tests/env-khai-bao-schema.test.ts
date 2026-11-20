// AUD-CFG-002 — mọi biến `process.env.X` mà code app/runtime đọc phải được khai trong schema zod
// của lib/nen/env.ts (nguồn khai tập trung, xem CLAUDE.md "Biến môi trường quan trọng").
// Chặn tái diễn: thêm biến vào code mà quên khai → biến không được validate/ghi chú, dễ sai im lặng.
// Biến của scripts/ (bench, DR, PITR…) là công cụ vận hành, không thuộc schema runtime nên không quét.
import { test } from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const ROOT = process.cwd();

// Do Next.js/Node tự đặt, không phải cấu hình của XBoss.
const DO_HE_THONG_DAT = new Set(["NEXT_RUNTIME"]);

const TEP_GOC = [
  "instrumentation.ts",
  "proxy.ts",
  "sentry.server.config.ts",
  "sentry.edge.config.ts",
];
const THU_MUC_QUET = ["app", "lib"];

function layTepMa(dir: string, ra: string[] = []): string[] {
  for (const ten of readdirSync(dir)) {
    const duongDan = join(dir, ten);
    if (statSync(duongDan).isDirectory()) layTepMa(duongDan, ra);
    else if (/\.(ts|tsx)$/.test(ten)) ra.push(duongDan);
  }
  return ra;
}

/** Tên biến được đọc qua `process.env.NAME` trong một đoạn mã. */
export function bienDocTrongMa(ma: string): string[] {
  return [...ma.matchAll(/process\.env\.([A-Z][A-Z0-9_]*)/g)].map((m) => m[1]);
}

/** Khoá khai trong schema (dòng thụt 4 ô: `    NAME:`) của lib/nen/env.ts. */
export function bienKhaiTrongSchema(nguon: string): Set<string> {
  return new Set([...nguon.matchAll(/^ {4}([A-Z][A-Z0-9_]*):/gm)].map((m) => m[1]));
}

test("bienDocTrongMa/bienKhaiTrongSchema: nhận đúng tên biến", () => {
  assert.deepEqual(bienDocTrongMa("a = process.env.FOO_1 ?? process.env.BAR"), ["FOO_1", "BAR"]);
  assert.deepEqual(
    [...bienKhaiTrongSchema("z.object({\n    FOO: z.string(),\n  x: 1,\n    BAR_2: z\n})")],
    ["FOO", "BAR_2"],
  );
});

test("AUD-CFG-002: mọi process.env.X trong app/ lib/ và file gốc đều khai trong lib/nen/env.ts", () => {
  const khaiBao = bienKhaiTrongSchema(readFileSync(join(ROOT, "lib/nen/env.ts"), "utf8"));
  assert.ok(khaiBao.size > 20, "đọc schema env.ts thất bại (không thấy khoá nào)");

  const tep = [
    ...THU_MUC_QUET.flatMap((d) => layTepMa(join(ROOT, d))),
    ...TEP_GOC.map((t) => join(ROOT, t)),
  ];
  const thieu = new Map<string, string[]>();
  for (const t of tep) {
    for (const ten of bienDocTrongMa(readFileSync(t, "utf8"))) {
      if (khaiBao.has(ten) || DO_HE_THONG_DAT.has(ten)) continue;
      thieu.set(ten, [...(thieu.get(ten) ?? []), t.slice(ROOT.length + 1)]);
    }
  }
  const bao = [...thieu].map(([ten, ds]) => `${ten} (đọc ở ${[...new Set(ds)].join(", ")})`);
  assert.deepEqual(bao, [], `Biến chưa khai trong lib/nen/env.ts: ${bao.join("; ")}`);
});
