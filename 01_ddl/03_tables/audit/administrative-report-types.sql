CREATE TABLE audit.administrative_report_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_administrative_report_types_code UNIQUE (code),
    CONSTRAINT chk_administrative_report_types_code CHECK (code IN ('FLEET_OCCUPANCY', 'REVENUE_SUMMARY', 'AUDIT_TRAIL', 'MAINTENANCE')),
    CONSTRAINT chk_administrative_report_types_name_not_blank CHECK (btrim(name) <> '')
);
