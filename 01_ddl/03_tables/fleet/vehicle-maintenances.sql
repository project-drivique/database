CREATE TABLE fleet.vehicle_maintenances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL,
    maintenance_type_id UUID NOT NULL,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    cost NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    description TEXT,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_maintenances_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_maintenances_type FOREIGN KEY (maintenance_type_id) REFERENCES fleet.maintenance_types (id),
    CONSTRAINT fk_vehicle_maintenances_created_by FOREIGN KEY (created_by) REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT chk_vehicle_maintenances_cost CHECK (cost >= 0),
    CONSTRAINT chk_vehicle_maintenances_dates CHECK (completed_date IS NULL OR completed_date >= scheduled_date)
);
