CREATE TABLE rental.reservation_additional_services (
    reservation_id UUID NOT NULL,
    additional_service_id UUID NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 1,
    daily_rate NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reservation_additional_services
        PRIMARY KEY (reservation_id, additional_service_id),
    CONSTRAINT fk_reservation_additional_services_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_additional_services_service
        FOREIGN KEY (additional_service_id) REFERENCES catalog.additional_services (id) ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_additional_services_quantity_positive
        CHECK (quantity > 0),
    CONSTRAINT chk_reservation_additional_services_daily_rate_nonnegative
        CHECK (daily_rate >= 0)
);
