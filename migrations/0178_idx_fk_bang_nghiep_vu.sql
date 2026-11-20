-- Audit D-009 AUD-DATA-001: nhiều khoá ngoại một cột không có index — join và kiểm tra khoá
-- ngoại khi xoá dòng cha (`SELECT 1 FROM con WHERE cot = $1 FOR KEY SHARE`) quét tuần tự.
-- Đợt này chỉ thêm cho khoá ngoại phục vụ join / chặn xoá cha-con ở bảng nghiệp vụ (tài chính,
-- vật tư, QC, chấm công). Cố ý CHƯA thêm: cột created_by/uploaded_by... trỏ users (xoá user hiếm),
-- 27 cột notifications.*_id (bảng ghi nhiều, đã có index một phần theo người nhận) — cần đo riêng.
-- Cột cho phép NULL dùng index một phần `WHERE cot IS NOT NULL` (nhỏ hơn, ghi rẻ hơn; planner vẫn
-- dùng cho `cot = $1` và cho truy vấn kiểm khoá ngoại).
-- Chỉ CREATE INDEX IF NOT EXISTS (thuần thêm, không đụng dữ liệu) — idempotent, đi thẳng production.

-- Vật tư
CREATE INDEX IF NOT EXISTS idx_materials_task ON materials (task_id) WHERE task_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_material_transactions_task ON material_transactions (task_id) WHERE task_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_material_transactions_receipt_item ON material_transactions (receipt_item_id) WHERE receipt_item_id IS NOT NULL;

-- Hợp đồng, hoá đơn, quỹ, thanh toán, claim, mua sắm
CREATE INDEX IF NOT EXISTS idx_boq_items_contract ON boq_items (contract_id) WHERE contract_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_invoices_contract ON invoices (contract_id) WHERE contract_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_invoices_payment_bill ON invoices (payment_bill_id) WHERE payment_bill_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_cash_transactions_contract ON cash_transactions (contract_id) WHERE contract_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_cash_transactions_supplier ON cash_transactions (supplier_id) WHERE supplier_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_contracts_party_supplier ON contracts (party_supplier_id) WHERE party_supplier_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payment_bills_payment_cert ON payment_bills (payment_cert_id) WHERE payment_cert_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payment_bills_sheet_type ON payment_bills (sheet_type_id) WHERE sheet_type_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_claims_vo ON claims (vo_id) WHERE vo_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier ON purchase_orders (supplier_id) WHERE supplier_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tender_bids_supplier ON tender_bids (supplier_id) WHERE supplier_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_advances_proposal ON advances (proposal_id) WHERE proposal_id IS NOT NULL;

-- QC / NCR / ảnh
CREATE INDEX IF NOT EXISTS idx_qc_inspections_checklist ON qc_inspections (checklist_id) WHERE checklist_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ncrs_inspection ON ncrs (inspection_id) WHERE inspection_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_task_photos_ncr ON task_photos (ncr_id) WHERE ncr_id IS NOT NULL;

-- Chấm công / lương
CREATE INDEX IF NOT EXISTS idx_attendance_crew ON attendance (crew_id) WHERE crew_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_attendance_personnel ON attendance (personnel_id) WHERE personnel_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payroll_crew ON payroll (crew_id) WHERE crew_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payroll_personnel ON payroll (personnel_id) WHERE personnel_id IS NOT NULL;
