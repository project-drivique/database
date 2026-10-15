ALTER TABLE rental.reservation_delivery_points
    DROP CONSTRAINT IF EXISTS fk_reservation_delivery_points_driver,
    DROP CONSTRAINT IF EXISTS chk_reservation_delivery_points_delivery_status,
    DROP COLUMN IF EXISTS driver_id,
    DROP COLUMN IF EXISTS delivery_pin,
    DROP COLUMN IF EXISTS delivery_status,
    DROP COLUMN IF EXISTS delivered_at;

DROP TABLE IF EXISTS location.delivery_drivers;
