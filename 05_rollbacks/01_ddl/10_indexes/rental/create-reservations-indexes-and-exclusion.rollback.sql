ALTER TABLE rental.reservations
    DROP CONSTRAINT IF EXISTS reservations_vehicle_period_no_overlap;
DROP INDEX IF EXISTS rental.idx_reservations_dates;
DROP INDEX IF EXISTS rental.idx_reservations_status;
DROP INDEX IF EXISTS rental.idx_reservations_vehicle;
DROP INDEX IF EXISTS rental.idx_reservations_customer;
