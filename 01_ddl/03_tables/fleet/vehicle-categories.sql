CREATE TABLE fleet.vehicle_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    base_daily_rate NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    security_deposit NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_categories_name UNIQUE (name),
    CONSTRAINT chk_vehicle_categories_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_vehicle_categories_base_daily_rate CHECK (base_daily_rate >= 0),
    CONSTRAINT chk_vehicle_categories_security_deposit CHECK (security_deposit >= 0)
);
