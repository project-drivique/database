CREATE TABLE contract.vehicle_inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL,
    inspection_type VARCHAR(20) NOT NULL,
    inspector_user_id UUID NOT NULL,
    mileage INTEGER NOT NULL,
    fuel_level_percent NUMERIC(5, 2) NOT NULL,
    observations TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_inspections_contract_type
        UNIQUE (contract_id, inspection_type),
    CONSTRAINT fk_vehicle_inspections_contract
        FOREIGN KEY (contract_id) REFERENCES contract.rental_contracts (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_inspections_inspector
        FOREIGN KEY (inspector_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_vehicle_inspections_type
        CHECK (inspection_type IN ('CHECK_IN', 'CHECK_OUT')),
    CONSTRAINT chk_vehicle_inspections_mileage_nonnegative
        CHECK (mileage >= 0),
    CONSTRAINT chk_vehicle_inspections_fuel_level_percent
        CHECK (fuel_level_percent >= 0.00 AND fuel_level_percent <= 100.00),
    CONSTRAINT chk_vehicle_inspections_observations_not_blank
        CHECK (observations IS NULL OR btrim(observations) <> '')
);
