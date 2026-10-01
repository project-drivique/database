CREATE INDEX idx_vehicles_plate ON fleet.vehicles (plate);
CREATE INDEX idx_vehicles_branch_status ON fleet.vehicles (current_branch_id, status_id, is_active);
CREATE INDEX idx_vehicles_cat_rate ON fleet.vehicles (category_id, daily_rate);
