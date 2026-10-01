BEGIN;

DO $$
DECLARE
    brand_id UUID;
    brand_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM fleet.vehicle_brands) < 11 THEN
        RAISE EXCEPTION 'Expected technical vehicle brand seeds';
    END IF;

    IF (SELECT COUNT(*) FROM fleet.transmission_types) <> 2
       OR NOT EXISTS (SELECT 1 FROM fleet.transmission_types WHERE code = 'MANUAL')
       OR NOT EXISTS (SELECT 1 FROM fleet.transmission_types WHERE code = 'AUTOMATIC') THEN
        RAISE EXCEPTION 'Expected MANUAL and AUTOMATIC transmission seeds';
    END IF;

    IF (SELECT COUNT(*) FROM fleet.fuel_types) <> 4
       OR NOT EXISTS (SELECT 1 FROM fleet.fuel_types WHERE code = 'GASOLINE')
       OR NOT EXISTS (SELECT 1 FROM fleet.fuel_types WHERE code = 'DIESEL')
       OR NOT EXISTS (SELECT 1 FROM fleet.fuel_types WHERE code = 'ELECTRIC')
       OR NOT EXISTS (SELECT 1 FROM fleet.fuel_types WHERE code = 'HYBRID') THEN
        RAISE EXCEPTION 'Expected all fuel type seeds';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM fleet.vehicle_statuses
        WHERE code = 'AVAILABLE' AND allows_reservation
    ) OR EXISTS (
        SELECT 1 FROM fleet.vehicle_statuses
        WHERE code IN ('RENTED', 'MAINTENANCE', 'INACTIVE')
          AND allows_reservation
    ) THEN
        RAISE EXCEPTION 'Expected only AVAILABLE vehicle status to allow reservations';
    END IF;

    BEGIN
        INSERT INTO fleet.transmission_types (code, name)
        VALUES ('MANUAL', 'Duplicate Manual');
        RAISE EXCEPTION 'Expected duplicated transmission code to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO fleet.fuel_types (code, name)
        VALUES ('electric', 'Invalid format');
        RAISE EXCEPTION 'Expected lowercase fuel code to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    SELECT id INTO brand_id
    FROM fleet.vehicle_brands
    WHERE name = 'Chevrolet';

    UPDATE fleet.vehicle_brands
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = brand_id;

    SELECT updated_at INTO brand_updated_at
    FROM fleet.vehicle_brands
    WHERE id = brand_id;

    IF brand_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected vehicle brands updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-17 APPROVED: technical catalogs, code constraints, seeds and reservation status validated.';
END;
$$;

ROLLBACK;
