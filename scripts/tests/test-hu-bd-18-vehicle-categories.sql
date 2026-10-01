BEGIN;

DO $$
DECLARE
    cat_id UUID;
    cat_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM fleet.vehicle_categories) <> 5 THEN
        RAISE EXCEPTION 'Expected exactly 5 vehicle category seeds';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM fleet.vehicle_categories WHERE name = 'SUV' AND base_daily_rate = 180000.00 AND security_deposit = 1500000.00)
       OR NOT EXISTS (SELECT 1 FROM fleet.vehicle_categories WHERE name = 'Sedán' AND base_daily_rate = 120000.00 AND security_deposit = 1000000.00)
       OR NOT EXISTS (SELECT 1 FROM fleet.vehicle_categories WHERE name = 'Hatchback' AND base_daily_rate = 100000.00 AND security_deposit = 800000.00)
       OR NOT EXISTS (SELECT 1 FROM fleet.vehicle_categories WHERE name = 'Camioneta' AND base_daily_rate = 220000.00 AND security_deposit = 2000000.00)
       OR NOT EXISTS (SELECT 1 FROM fleet.vehicle_categories WHERE name = 'Lujo' AND base_daily_rate = 350000.00 AND security_deposit = 3000000.00) THEN
        RAISE EXCEPTION 'Expected all vehicle category seeds with correct rates and deposits';
    END IF;

    -- Test unique name constraint
    BEGIN
        INSERT INTO fleet.vehicle_categories (name, base_daily_rate, security_deposit)
        VALUES ('SUV', 200000.00, 1000000.00);
        RAISE EXCEPTION 'Expected duplicate category name to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- Test non-negative base_daily_rate check constraint
    BEGIN
        INSERT INTO fleet.vehicle_categories (name, base_daily_rate, security_deposit)
        VALUES ('Coupé', -100.00, 500000.00);
        RAISE EXCEPTION 'Expected negative base_daily_rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- Test non-negative security_deposit check constraint
    BEGIN
        INSERT INTO fleet.vehicle_categories (name, base_daily_rate, security_deposit)
        VALUES ('Convertible', 250000.00, -500.00);
        RAISE EXCEPTION 'Expected negative security_deposit to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- Test updated_at trigger
    SELECT id INTO cat_id
    FROM fleet.vehicle_categories
    WHERE name = 'SUV';

    UPDATE fleet.vehicle_categories
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = cat_id;

    SELECT updated_at INTO cat_updated_at
    FROM fleet.vehicle_categories
    WHERE id = cat_id;

    IF cat_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected vehicle categories updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-18 APPROVED: vehicle categories, constraints, seeds, and triggers validated.';
END;
$$;

ROLLBACK;
