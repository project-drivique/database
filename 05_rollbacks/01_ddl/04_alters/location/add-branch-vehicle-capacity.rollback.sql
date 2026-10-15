ALTER TABLE location.branches DROP CONSTRAINT IF EXISTS chk_branches_vehicle_capacity_positive;
ALTER TABLE location.branches DROP COLUMN IF EXISTS vehicle_capacity;
