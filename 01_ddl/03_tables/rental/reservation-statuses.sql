CREATE TABLE rental.reservation_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    blocks_availability BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_reservation_statuses_code UNIQUE (code),
    CONSTRAINT chk_reservation_statuses_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_reservation_statuses_name_not_blank CHECK (btrim(name) <> '')
);
