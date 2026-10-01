CREATE TABLE fleet.user_favorite_vehicles (
    user_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, vehicle_id),
    CONSTRAINT fk_user_favorite_vehicles_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_favorite_vehicles_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE
);
