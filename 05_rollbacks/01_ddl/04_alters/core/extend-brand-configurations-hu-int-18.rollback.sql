ALTER TABLE core.brand_configurations
    DROP COLUMN IF EXISTS previous_snapshot;

UPDATE core.brand_configurations SET logo_url = NULL WHERE logo_url IS NOT NULL AND length(logo_url) > 2048;

ALTER TABLE core.brand_configurations
    ALTER COLUMN logo_url TYPE VARCHAR(2048);
