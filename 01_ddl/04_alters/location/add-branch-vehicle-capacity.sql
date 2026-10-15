ALTER TABLE location.branches
    ADD COLUMN IF NOT EXISTS vehicle_capacity INTEGER NOT NULL DEFAULT 20;

ALTER TABLE location.branches
    ADD CONSTRAINT chk_branches_vehicle_capacity_positive CHECK (vehicle_capacity > 0);
