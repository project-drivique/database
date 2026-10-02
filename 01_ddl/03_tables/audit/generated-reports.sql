CREATE TABLE audit.generated_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_type_id UUID NOT NULL,
    format VARCHAR(20) NOT NULL,
    generated_by UUID NOT NULL,
    filters JSONB NOT NULL DEFAULT '{}'::jsonb,
    file_url VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    generated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_generated_reports_type FOREIGN KEY (report_type_id) REFERENCES audit.administrative_report_types (id) ON DELETE RESTRICT,
    CONSTRAINT fk_generated_reports_generated_by FOREIGN KEY (generated_by) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_generated_reports_format CHECK (format IN ('PDF', 'EXCEL', 'WORD', 'CSV')),
    CONSTRAINT chk_generated_reports_status CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    CONSTRAINT chk_generated_reports_file_url_not_blank CHECK (file_url IS NULL OR btrim(file_url) <> '')
);
