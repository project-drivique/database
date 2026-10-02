CREATE TABLE rental.vehicle_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating SMALLINT NOT NULL,
    comment VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_ratings_reservation UNIQUE (reservation_id),
    CONSTRAINT fk_vehicle_ratings_reservation FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE RESTRICT,
    CONSTRAINT fk_vehicle_ratings_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE RESTRICT,
    CONSTRAINT fk_vehicle_ratings_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_vehicle_ratings_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_vehicle_ratings_comment_not_blank CHECK (comment IS NULL OR btrim(comment) <> '')
);
