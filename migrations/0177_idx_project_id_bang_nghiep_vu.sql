-- Audit D-009 AUD-DATA-002: 46 bảng có cột project_id nhưng không có index nào bắt đầu bằng
-- project_id — mọi truy vấn lọc theo dự án (và điều kiện RLS app.project_id) quét tuần tự.
-- Đợt này chỉ thêm cho nhóm bảng NGHIỆP VỤ lọc theo dự án và lớn dần theo thời gian; bảng cấu
-- hình nhỏ (feature_flags, nav_settings, role_permissions, raci_matrix…) và bảng lớp
-- engineering_* chưa thêm (chi phí ghi > lợi ích đọc, hoặc cần đo riêng).
-- Chỉ CREATE INDEX IF NOT EXISTS (thuần thêm, không đụng dữ liệu) — idempotent, đi thẳng production.

-- Nhật ký + duyệt: truy vấn điển hình lọc dự án rồi sắp theo thời gian / trạng thái.
CREATE INDEX IF NOT EXISTS idx_audit_log_project_at ON audit_log (project_id, at DESC);
CREATE INDEX IF NOT EXISTS idx_approval_requests_project_status ON approval_requests (project_id, status);

-- Nhân sự, mặt bằng, bàn giao, hồ sơ pháp lý/bảo hiểm/chứng chỉ, bảo hành, môi trường, HSE-khác.
CREATE INDEX IF NOT EXISTS idx_personnel_project ON personnel (project_id);
CREATE INDEX IF NOT EXISTS idx_towers_project ON towers (project_id);
CREATE INDEX IF NOT EXISTS idx_sheet_types_project ON sheet_types (project_id);
CREATE INDEX IF NOT EXISTS idx_handover_items_project ON handover_items (project_id);
CREATE INDEX IF NOT EXISTS idx_punch_list_project ON punch_list (project_id);
CREATE INDEX IF NOT EXISTS idx_certifications_project ON certifications (project_id);
CREATE INDEX IF NOT EXISTS idx_insurance_bonds_project ON insurance_bonds (project_id);
CREATE INDEX IF NOT EXISTS idx_legal_documents_project ON legal_documents (project_id);
CREATE INDEX IF NOT EXISTS idx_warranty_claims_project ON warranty_claims (project_id);
CREATE INDEX IF NOT EXISTS idx_warranty_items_project ON warranty_items (project_id);
CREATE INDEX IF NOT EXISTS idx_env_monitoring_project ON env_monitoring (project_id);
CREATE INDEX IF NOT EXISTS idx_env_permits_project ON env_permits (project_id);
CREATE INDEX IF NOT EXISTS idx_waste_logs_project ON waste_logs (project_id);
CREATE INDEX IF NOT EXISTS idx_community_cases_project ON community_cases (project_id);
CREATE INDEX IF NOT EXISTS idx_om_documents_project ON om_documents (project_id);
CREATE INDEX IF NOT EXISTS idx_progress_albums_project ON progress_albums (project_id);
CREATE INDEX IF NOT EXISTS idx_mobilization_items_project ON mobilization_items (project_id);
CREATE INDEX IF NOT EXISTS idx_demob_items_project ON demob_items (project_id);
CREATE INDEX IF NOT EXISTS idx_commissioning_project ON commissioning (project_id);
CREATE INDEX IF NOT EXISTS idx_lessons_learned_project ON lessons_learned (project_id);
CREATE INDEX IF NOT EXISTS idx_tech_links_project ON tech_links (project_id);
