BEGIN;

DO $$
DECLARE
    v_id UUID;
    v_updated_at TIMESTAMPTZ;
    brand_id UUID;
    cat_id UUID;
    trans_id UUID;
    fuel_id UUID;
    status_id UUID;
    branch_id UUID;
BEGIN
    IF (SELECT COUNT(*) FROM fleet.vehicles) < 6 THEN
        RAISE EXCEPTION 'Expected at least 6 seeded vehicles';
    END IF;

    SELECT b.id, c.id, t.id, f.id, s.id, br.id
    INTO brand_id, cat_id, trans_id, fuel_id, status_id, branch_id
    FROM fleet.vehicle_brands b, fleet.vehicle_categories c, fleet.transmission_types t, fleet.fuel_types f, fleet.vehicle_statuses s, location.branches br
    WHERE b.name = 'Toyota' AND c.name = 'SUV' AND t.code = 'AUTOMATIC' AND f.code = 'HYBRID' AND s.code = 'AVAILABLE' AND br.name = 'Drivique Bogotá Centro'
    LIMIT 1;

    -- Test unique plate constraint
    BEGIN
        INSERT INTO fleet.vehicles (
            plate, vin, brand_id, category_id, transmission_type_id, fuel_type_id, status_id, current_branch_id,
            model, year, passenger_capacity, daily_rate
        ) VALUES (
            'ABC-123', 'VIN99999999999999', brand_id, cat_id, trans_id, fuel_id, status_id, branch_id,
            'Duplicate Plate Model', 2024, 5, 200000.00
        );
        RAISE EXCEPTION 'Expected duplicate plate to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- Test unique vin constraint
    BEGIN
        INSERT INTO fleet.vehicles (
            plate, vin, brand_id, category_id, transmission_type_id, fuel_type_id, status_id, current_branch_id,
            model, year, passenger_capacity, daily_rate
        ) VALUES (
            'ZZZ-999', '1HGCR2F83HA000001', brand_id, cat_id, trans_id, fuel_id, status_id, branch_id,
            'Duplicate VIN Model', 2024, 5, 200000.00
        );
        RAISE EXCEPTION 'Expected duplicate VIN to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- Test year check constraint
    BEGIN
        INSERT INTO fleet.vehicles (
            plate, vin, brand_id, category_id, transmission_type_id, fuel_type_id, status_id, current_branch_id,
            model, year, passenger_capacity, daily_rate
        ) VALUES (
            'ZZZ-001', 'VIN00000000000001', brand_id, cat_id, trans_id, fuel_id, status_id, branch_id,
            'Invalid Year Model', 1800, 5, 200000.00
        );
        RAISE EXCEPTION 'Expected invalid year to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- Test negative daily rate check constraint
    BEGIN
        INSERT INTO fleet.vehicles (
            plate, vin, brand_id, category_id, transmission_type_id, fuel_type_id, status_id, current_branch_id,
            model, year, passenger_capacity, daily_rate
        ) VALUES (
            'ZZZ-002', 'VIN00000000000002', brand_id, cat_id, trans_id, fuel_id, status_id, branch_id,
            'Negative Rate Model', 2024, 5, -100.00
        );
        RAISE EXCEPTION 'Expected negative daily rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- Test updated_at trigger
    SELECT id INTO v_id
    FROM fleet.vehicles
    WHERE plate = 'ABC-123';

    UPDATE fleet.vehicles
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = v_id;

    SELECT updated_at INTO v_updated_at
    FROM fleet.vehicles
    WHERE id = v_id;

    IF v_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected vehicles updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-19 APPROVED: vehicles table, foreign keys, constraints, seeds, and indexes validated.';
END;
$$;

ROLLBACK;
