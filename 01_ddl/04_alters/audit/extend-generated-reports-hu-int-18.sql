ALTER TABLE audit.administrative_report_types
    DROP CONSTRAINT IF EXISTS chk_administrative_report_types_code;

ALTER TABLE audit.administrative_report_types
    ADD CONSTRAINT chk_administrative_report_types_code_format CHECK (code ~ '^[A-Z][A-Z0-9_]{2,49}$');

ALTER TABLE audit.generated_reports
    ADD COLUMN report_code VARCHAR(40),
    ADD COLUMN title VARCHAR(200),
    ADD COLUMN total_records INT NOT NULL DEFAULT 0,
    ADD COLUMN snapshot JSONB;
