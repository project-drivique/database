ALTER TABLE location.branches
    DROP CONSTRAINT IF EXISTS chk_branches_latitude_range,
    DROP CONSTRAINT IF EXISTS chk_branches_longitude_range,
    DROP COLUMN IF EXISTS pickup_instructions,
    DROP COLUMN IF EXISTS latitude,
    DROP COLUMN IF EXISTS longitude;
