CREATE TABLE fleet.vehicle_features (
    vehicle_id UUID NOT NULL,
    feature_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (vehicle_id, feature_id),
    CONSTRAINT fk_vehicle_features_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_features_feature FOREIGN KEY (feature_id) REFERENCES fleet.features (id) ON DELETE CASCADE
);
