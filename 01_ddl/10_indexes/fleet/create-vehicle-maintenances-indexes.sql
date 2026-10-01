CREATE INDEX idx_vehicle_maintenances_veh ON fleet.vehicle_maintenances (vehicle_id);
CREATE INDEX idx_vehicle_maintenances_type ON fleet.vehicle_maintenances (maintenance_type_id);
CREATE INDEX idx_vehicle_maintenances_scheduled ON fleet.vehicle_maintenances (scheduled_date);
