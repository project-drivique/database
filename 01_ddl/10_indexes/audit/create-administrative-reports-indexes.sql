CREATE INDEX idx_administrative_report_types_code ON audit.administrative_report_types (code);
CREATE INDEX idx_generated_reports_type ON audit.generated_reports (report_type_id);
CREATE INDEX idx_generated_reports_generated_by ON audit.generated_reports (generated_by);
CREATE INDEX idx_generated_reports_format ON audit.generated_reports (format);
CREATE INDEX idx_generated_reports_generated_at ON audit.generated_reports (generated_at);
CREATE INDEX idx_generated_reports_filters ON audit.generated_reports USING gin (filters);
