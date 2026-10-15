ALTER TABLE core.brand_configurations
    ALTER COLUMN logo_url TYPE TEXT;

ALTER TABLE core.brand_configurations
    ADD COLUMN IF NOT EXISTS previous_snapshot JSONB;
