CREATE TABLE catalog.mileage_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    included_km INT,
    daily_rate NUMERIC(12, 2) NOT NULL,
    extra_km_rate NUMERIC(12, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_mileage_plans_name UNIQUE (name),
    CONSTRAINT chk_mileage_plans_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_mileage_plans_included_km_nonnegative CHECK (included_km IS NULL OR included_km >= 0),
    CONSTRAINT chk_mileage_plans_daily_rate_nonnegative CHECK (daily_rate >= 0),
    CONSTRAINT chk_mileage_plans_extra_km_rate_nonnegative CHECK (extra_km_rate >= 0)
);
