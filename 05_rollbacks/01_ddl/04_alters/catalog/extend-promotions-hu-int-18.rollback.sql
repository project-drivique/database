ALTER TABLE catalog.promotions
    DROP CONSTRAINT IF EXISTS chk_promotions_audience,
    DROP CONSTRAINT IF EXISTS chk_promotions_minimum_amount,
    DROP COLUMN IF EXISTS name,
    DROP COLUMN IF EXISTS conditions,
    DROP COLUMN IF EXISTS minimum_amount,
    DROP COLUMN IF EXISTS vehicle_category_id,
    DROP COLUMN IF EXISTS vehicle_id,
    DROP COLUMN IF EXISTS audience,
    DROP COLUMN IF EXISTS is_featured;
