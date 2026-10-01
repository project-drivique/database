CREATE TABLE fleet.maintenance_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL,
    name VARCHAR(80) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_maintenance_types_code UNIQUE (code),
    CONSTRAINT uq_maintenance_types_name UNIQUE (name),
    CONSTRAINT chk_maintenance_types_code CHECK (code IN ('PREVENTIVE', 'CORRECTIVE', 'OIL_CHANGE', 'TIRES'))
);
