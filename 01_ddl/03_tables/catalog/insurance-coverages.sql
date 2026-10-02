CREATE TABLE catalog.insurance_coverages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    daily_rate NUMERIC(12, 2) NOT NULL,
    description TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_insurance_coverages_name UNIQUE (name),
    CONSTRAINT chk_insurance_coverages_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_insurance_coverages_description_not_blank CHECK (btrim(description) <> ''),
    CONSTRAINT chk_insurance_coverages_daily_rate_nonnegative CHECK (daily_rate >= 0)
);
