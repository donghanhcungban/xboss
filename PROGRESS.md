# Tiến độ — 07/11/2026

## Đang làm

- **Audit D-009 đợt 5e — branch `claude/zen-lovelace-n3t0t7`**: 🟢 DATA-001 (một phần) — migration `0178` thêm 22 index khoá ngoại nghiệp vụ (phần lớn index một phần `WHERE cột IS NOT NULL`; chỉ `CREATE INDEX IF NOT EXISTS`, đi thẳng production); ERD sinh lại. Dọn PROGRESS.md: chuyển các mục đợt 1–4f sang `docs/ops/progress-history.md` (còn 4,5 KB). Chưa thêm: `created_by`→users, `notifications.*_id`.

- **Audit D-009 đợt 5d — MERGED qua #754** `26e5f6e8`: 🟢 DATA-002 (một phần) — migration `0177` thêm index `project_id` cho 23 bảng nghiệp vụ (chỉ `CREATE INDEX IF NOT EXISTS`, thuần thêm → đi thẳng production, không cần staging); ERD sinh lại. Còn 25 bảng cấu hình/engineering/payment_cert_adjustment chưa thêm (cần đo).

- **Audit D-009 đợt 5c — MERGED qua #753** `fdcc5dca`: 🟢 CODE-005 (một phần) — SSE `/api/events` log lần lỗi đầu của chuỗi lỗi kiểm watermark thay vì nuốt im lặng (test `route-events-loi-db`, đỏ-trước). Còn: `material-sync` snapshot hỏng (vùng §8), PATCH tasks/:id.

- **Audit D-009 đợt 5b — MERGED qua #751** `f8a6c49e`: 🟢 CFG-002 (một phần) — test `env-khai-bao-schema` đối chiếu mọi `process.env.X` ở `app/`, `lib/`, file gốc với schema `lib/nen/env.ts` (đỏ nếu quên khai). Còn: đối chiếu `.env.example` (owner/CI).

- **Audit D-009 đợt 5a — MERGED qua #750** `1e23c975`: 🟢 DEP-001/002 (một phần) — thêm `engines.node >=24`, bỏ `better-sqlite3` thừa khỏi `next.config.mjs`; `npm audit --omit=dev` còn 4 moderate (chuỗi exceljs→minimatch).

- **Nâng `next` 16.4.3→16.4.6 — MERGED qua #749** `ee2a9a42`, `eslint-config-next` →16.4.6, `@sentry/nextjs` →11.15.0** vá advisory moderate (khoảng 16.2.0–16.4.4); build cục bộ từng đỏ `SecurityFatalError` vì advisory này.

- **OCR 1.13.9→1.13.10 — MERGED qua #748** `6f0a7c51` (thay #741 của dependabot đỏ vì test ghim phiên bản).

## Tiếp theo

- Lịch sử các mục đã merge/deploy: `docs/ops/progress-history.md`. Bảng nợ kỹ thuật TD-xxx: `docs/ops/technical-debt-2026-10-26.md` (mục cuối). Phát hiện audit: `docs/ops/AUDIT-STATUS.md`.
- Audit D-009 đợt 4: quét sâu lại 8 nhóm `chưa quét` (đọc từng route theo `docs/audit.md` §3/§8) + đối soát 1170 MUST blueprint.
- M136: owner bố trí UAT 3–5 người và Safari/cảm ứng thật theo runbook; operator xác nhận nguồn/coverage/thời điểm thu usage trước pilot. PR đối soát và vá Zod **#676** đã merge/deploy; F4 VERIFIED; plan `docs/autopilot/M136-RELEASE-PLAN.md`; public smoke chưa chứng minh lỗi app mới; bản vá dependency phát sinh được ghi riêng ở trên.
- A2 còn mở: Safari/iOS thiết bị thật (cần người); ảnh mồ côi giữ P/H S06.
- Chọn lát S15 tiếp theo hoặc audit 1152 MUST/639 SHOULD.

## Quyết định

D-A2-001 tự duyệt lát B theo QUALITY-FINAL-1 Approved 25/09/2026. D-A2-002 (mức S): vá `OfflineQueueBadge` không mount lại màn phục hồi khi hàng đợi về 0 (RED trước vá ở `.autopilot/runtime/a2-run4.log`). #663 `2adda49d`, #664 `8fc15d89`, #665 `9c13f54a`, #666 `273a09d`, #668 `6690593` đã merge. A2/S15 giữ PARTIAL tổng thể.

Đã xong 23/10: **#673** `a7530e9` (M135 kéo thả nhóm/tầng + task trên lưới tracking, `@dnd-kit`, `PUT /api/workpackages` + `PUT /api/workpackages/:id/tasks`; test 14/14 + e2e kéo thật; chưa thử cảm ứng trên điện thoại thật). **#672** `8b043e1` (PROGRESS). **#667** `bbcfd43` (A1 API-key write hai org, test 7/7 Postgres). **#670** `1aef49f` (deploy đọc `VPS_SSH_KNOWN_HOSTS` từ variable; nâng `next`/`eslint-config-next` 16.4.2 vá advisory critical). **#671** `fb5075e` (deploy chuẩn hoá known_hosts — gắn nhãn host = `VPS_HOST`, khoá ghim giữ nguyên, fail-closed; `scripts/ops/chuan-hoa-known-hosts.sh`, test 11/11). **Deploy to VPS xanh lại**: run 39910066732 qua SSH + gửi build + deploy.sh. CodeQL `js/insufficient-password-hash` ở `hashApiKey` là báo sai (key 256 bit ngẫu nhiên) — nếu còn mở cần chủ repo dismiss.

## Bàn giao phiên

Mốc main đã đối soát ngày28/10: `4cf72488` (CI/deploy success); #675–#696 đã phát hành theo bằng chứng từng PR, không còn chờ CI #686. Owner giữ UAT/usage WAITING; chưa có nghiệm thu người thật hoặc cửa sổ usage. Goal tháng8 Product/Vision/Pinnacle đã ghi checkpoint đối soát, không dùng kết luận COMPLETE lịch sử cho sản phẩm hiện tại hay khôi phục module đã gỡ. QUALITY-FINAL-1/A1–A6 vẫn PARTIAL. Bản vá XSS/tài liệu đã merge qua #687 (`7805949`); M138 chưa approved. Runtime local Node24.22.1/Postgres16 disposable; không đổi production. Toàn1152 MUST/639 SHOULD chưa audit đầy đủ.
