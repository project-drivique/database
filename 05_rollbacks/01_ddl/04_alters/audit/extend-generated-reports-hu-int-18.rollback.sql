ALTER TABLE audit.generated_reports
    DROP COLUMN IF EXISTS report_code,
    DROP COLUMN IF EXISTS title,
    DROP COLUMN IF EXISTS total_records,
    DROP COLUMN IF EXISTS snapshot;

ALTER TABLE audit.administrative_report_types
    DROP CONSTRAINT IF EXISTS chk_administrative_report_types_code_format;

ALTER TABLE audit.administrative_report_types
    ADD CONSTRAINT chk_administrative_report_types_code CHECK (code IN ('FLEET_OCCUPANCY', 'REVENUE_SUMMARY', 'AUDIT_TRAIL', 'MAINTENANCE'));
