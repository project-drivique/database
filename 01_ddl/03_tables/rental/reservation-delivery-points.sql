CREATE TABLE rental.reservation_delivery_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL,
    point_type VARCHAR(10) NOT NULL,
    modality VARCHAR(20) NOT NULL,
    branch_id UUID,
    city_id UUID,
    neighborhood VARCHAR(120),
    address VARCHAR(255),
    flight_or_bus_number VARCHAR(60),
    reference_details VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservation_delivery_points_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_delivery_points_branch
        FOREIGN KEY (branch_id) REFERENCES location.branches (id),
    CONSTRAINT fk_reservation_delivery_points_city
        FOREIGN KEY (city_id) REFERENCES location.cities (id),
    CONSTRAINT uq_reservation_delivery_points_reservation_point_type
        UNIQUE (reservation_id, point_type),
    CONSTRAINT chk_reservation_delivery_points_point_type
        CHECK (point_type IN ('PICKUP', 'RETURN')),
    CONSTRAINT chk_reservation_delivery_points_modality
        CHECK (modality IN ('BRANCH', 'HOME_DELIVERY', 'AIRPORT', 'TERMINAL')),
    CONSTRAINT chk_reservation_delivery_points_modality_data
        CHECK (
            (modality = 'BRANCH' AND branch_id IS NOT NULL AND city_id IS NULL AND address IS NULL)
            OR (modality = 'HOME_DELIVERY' AND branch_id IS NULL AND city_id IS NOT NULL AND address IS NOT NULL)
            OR (modality IN ('AIRPORT', 'TERMINAL') AND branch_id IS NULL AND city_id IS NOT NULL)
        ),
    CONSTRAINT chk_reservation_delivery_points_neighborhood_not_blank
        CHECK (neighborhood IS NULL OR btrim(neighborhood) <> ''),
    CONSTRAINT chk_reservation_delivery_points_address_not_blank
        CHECK (address IS NULL OR btrim(address) <> ''),
    CONSTRAINT chk_reservation_delivery_points_flight_or_bus_number_not_blank
        CHECK (flight_or_bus_number IS NULL OR btrim(flight_or_bus_number) <> ''),
    CONSTRAINT chk_reservation_delivery_points_reference_details_not_blank
        CHECK (reference_details IS NULL OR btrim(reference_details) <> '')
);
