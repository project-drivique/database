CREATE TABLE fleet.fuel_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_fuel_types_code UNIQUE (code),
    CONSTRAINT chk_fuel_types_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_fuel_types_name_not_blank CHECK (btrim(name) <> '')
);
