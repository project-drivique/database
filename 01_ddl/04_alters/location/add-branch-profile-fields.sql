ALTER TABLE location.branches
    ADD COLUMN IF NOT EXISTS pickup_instructions VARCHAR(500),
    ADD COLUMN IF NOT EXISTS latitude NUMERIC(9, 6),
    ADD COLUMN IF NOT EXISTS longitude NUMERIC(9, 6);

ALTER TABLE location.branches
    ADD CONSTRAINT chk_branches_latitude_range CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    ADD CONSTRAINT chk_branches_longitude_range CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);
