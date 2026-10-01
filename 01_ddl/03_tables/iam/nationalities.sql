CREATE TABLE iam.nationalities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    iso_code CHAR(2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_nationalities_name UNIQUE (name),
    CONSTRAINT uq_nationalities_iso_code UNIQUE (iso_code),
    CONSTRAINT chk_nationalities_iso_code_format CHECK (iso_code ~ '^[A-Z]{2}$')
);
