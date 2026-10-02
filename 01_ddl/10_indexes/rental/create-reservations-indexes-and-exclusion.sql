ALTER TABLE rental.reservations
    ADD CONSTRAINT reservations_vehicle_period_no_overlap
    EXCLUDE USING GIST (
        vehicle_id WITH =,
        tstzrange(pickup_date, return_date, '[)') WITH &&
    )
    WHERE (blocks_availability);

CREATE INDEX idx_reservations_customer ON rental.reservations (customer_id);
CREATE INDEX idx_reservations_vehicle ON rental.reservations (vehicle_id);
CREATE INDEX idx_reservations_status ON rental.reservations (status_id);
CREATE INDEX idx_reservations_dates ON rental.reservations (pickup_date, return_date);
