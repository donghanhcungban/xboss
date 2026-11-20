import "./setup";
import { mock, test } from "node:test";
import assert from "node:assert/strict";
import { NextRequest } from "next/server";

// AUD-CODE-005 — GET /api/events (SSE) nuốt lỗi kiểm watermark im lặng: DB hỏng kéo dài không
// để lại dấu vết nào. Chốt: lỗi lần đầu của một chuỗi lỗi liên tiếp phải được log (không tràn
// log mỗi chu kỳ), thành công thì đặt lại để chuỗi lỗi sau lại được log.
const warns: Array<{ msg: string; fields?: Record<string, unknown> }> = [];
let versionKetQua: Array<string | Error> = [];

mock.module("@/lib/bao-mat/auth", {
  namedExports: { getCurrentUser: async () => ({ id: 1, role: "admin", orgId: 1 }) },
});
mock.module("@/lib/ha-tang/projects", {
  namedExports: { getCurrentProjectId: async () => 1 },
});
mock.module("@/lib/ha-tang/feature-flags", {
  namedExports: { assertModuleEnabled: async () => null },
});
mock.module("@/lib/ha-tang/version", {
  namedExports: {
    sheetVersionShared: async () => {
      const kq = versionKetQua.shift();
      if (kq instanceof Error) throw kq;
      return kq ?? "v-het";
    },
  },
});
mock.module("@/lib/nen/log", {
  namedExports: {
    log: {
      info: () => {},
      error: () => {},
      warn: (msg: string, fields?: Record<string, unknown>) => warns.push({ msg, fields }),
    },
  },
});

async function chay(ketQua: Array<string | Error>, soChuKy: number) {
  warns.length = 0;
  versionKetQua = [...ketQua];
  mock.timers.enable({ apis: ["setInterval"] });
  try {
    const { GET } = await import("@/app/api/events/route");
    const ac = new AbortController();
    const res = await GET(
      new NextRequest("http://localhost/api/events?sheet=ogtd", { signal: ac.signal }),
    );
    // setInterval chỉ được tạo sau khi lần kiểm đầu (lúc mở stream) xong — chờ một nhịp.
    await new Promise((r) => setImmediate(r));
    for (let i = 0; i < soChuKy; i++) {
      mock.timers.tick(3_000);
      await new Promise((r) => setImmediate(r)); // cho check() async xử lý xong
    }
    await res.body?.cancel();
  } finally {
    mock.timers.reset();
  }
}

test("SSE /api/events: DB lỗi liên tiếp → chỉ log lần đầu của chuỗi lỗi", async () => {
  const loi = new Error("db sập");
  await chay([loi, loi, loi, loi], 3);
  assert.equal(warns.length, 1, `phải log đúng 1 lần, thực tế ${warns.length}`);
  assert.equal(warns[0].fields?.sheet, "ogtd");
  assert.equal(warns[0].fields?.err, "db sập");
});

test("SSE /api/events: thành công giữa chừng đặt lại chuỗi lỗi → lỗi sau log tiếp", async () => {
  const loi = new Error("db chập");
  // lần check đầu (khi mở stream) lỗi, rồi thành công, rồi lỗi lại
  await chay([loi, "v1", loi], 2);
  assert.equal(warns.length, 2);
});
