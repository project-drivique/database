BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    confirmed_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    branch_id UUID;
    city_id UUID;
    reservation_id UUID;
    reservation_id_2 UUID;
    point_id UUID;
    created_ts TIMESTAMPTZ;
    updated_ts TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO confirmed_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';
    SELECT id INTO city_id FROM location.cities WHERE name = 'Bogotá';

    IF admin_user_id IS NULL OR vehicle_id IS NULL OR confirmed_status_id IS NULL
       OR coverage_id IS NULL OR mileage_plan_id IS NULL OR branch_id IS NULL OR city_id IS NULL THEN
        RAISE EXCEPTION 'Expected prerequisite seeds for delivery points test';
    END IF;

    -- 1. Create reservation
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-DELIV-001', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '20 days', CURRENT_TIMESTAMP + INTERVAL '22 days',
        200000.00, 400000.00
    ) RETURNING id INTO reservation_id;

    -- 2. Insert valid PICKUP delivery point (BRANCH modality)
    INSERT INTO rental.reservation_delivery_points (
        reservation_id, point_type, modality, branch_id
    ) VALUES (
        reservation_id, 'PICKUP', 'BRANCH', branch_id
    ) RETURNING id, created_at, updated_at INTO point_id, created_ts, updated_ts;

    IF point_id IS NULL OR created_ts IS NULL OR updated_ts IS NULL THEN
        RAISE EXCEPTION 'Failed to insert branch pickup delivery point';
    END IF;

    -- 3. Insert valid RETURN delivery point (HOME_DELIVERY modality)
    INSERT INTO rental.reservation_delivery_points (
        reservation_id, point_type, modality, city_id, neighborhood, address, reference_details
    ) VALUES (
        reservation_id, 'RETURN', 'HOME_DELIVERY', city_id, 'Chapinero Alto', 'Calle 65 # 4-12 Apto 301', 'Frente al parque'
    );

    -- 4. Verify UNIQUE constraint (reservation_id, point_type): cannot insert duplicate PICKUP
    BEGIN
        INSERT INTO rental.reservation_delivery_points (
            reservation_id, point_type, modality, branch_id
        ) VALUES (
            reservation_id, 'PICKUP', 'BRANCH', branch_id
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate PICKUP delivery point';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 5. Test AIRPORT and TERMINAL modalities with flight_or_bus_number
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-DELIV-002', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '25 days', CURRENT_TIMESTAMP + INTERVAL '27 days',
        200000.00, 400000.00
    ) RETURNING id INTO reservation_id_2;

    INSERT INTO rental.reservation_delivery_points (
        reservation_id, point_type, modality, city_id, flight_or_bus_number, reference_details
    ) VALUES (
        reservation_id_2, 'PICKUP', 'AIRPORT', city_id, 'AV9345', 'Puerta 4 Llegadas Nacionales'
    );

    INSERT INTO rental.reservation_delivery_points (
        reservation_id, point_type, modality, city_id, flight_or_bus_number, reference_details
    ) VALUES (
        reservation_id_2, 'RETURN', 'TERMINAL', city_id, 'BOL-102', 'Módulo 2 Salitre'
    );

    -- 6. Check constraints: BRANCH without branch_id
    BEGIN
        INSERT INTO rental.reservation_delivery_points (
            reservation_id, point_type, modality, branch_id
        ) VALUES (
            reservation_id_2, 'PICKUP', 'BRANCH', NULL
        );
        RAISE EXCEPTION 'Expected check violation for BRANCH without branch_id';
    EXCEPTION WHEN check_violation OR not_null_violation OR unique_violation THEN NULL;
    END;

    -- 7. Check constraints: HOME_DELIVERY without address
    BEGIN
        INSERT INTO rental.reservation_delivery_points (
            reservation_id, point_type, modality, city_id, address
        ) VALUES (
            reservation_id_2, 'PICKUP', 'HOME_DELIVERY', city_id, NULL
        );
        RAISE EXCEPTION 'Expected check violation for HOME_DELIVERY without address';
    EXCEPTION WHEN check_violation OR not_null_violation OR unique_violation THEN NULL;
    END;

    -- 8. Check constraints: Invalid point_type
    BEGIN
        INSERT INTO rental.reservation_delivery_points (
            reservation_id, point_type, modality, branch_id
        ) VALUES (
            reservation_id_2, 'UNKNOWN', 'BRANCH', branch_id
        );
        RAISE EXCEPTION 'Expected check violation for invalid point_type';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 9. Check constraints: Invalid modality
    BEGIN
        INSERT INTO rental.reservation_delivery_points (
            reservation_id, point_type, modality, branch_id
        ) VALUES (
            reservation_id_2, 'PICKUP', 'STATION', branch_id
        );
        RAISE EXCEPTION 'Expected check violation for invalid modality';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 10. Verify ON DELETE CASCADE
    DELETE FROM rental.reservations WHERE id = reservation_id_2;

    IF EXISTS (
        SELECT 1 FROM rental.reservation_delivery_points
        WHERE reservation_id = reservation_id_2
    ) THEN
        RAISE EXCEPTION 'Expected delivery points to be deleted when reservation is deleted';
    END IF;

    RAISE NOTICE 'HU-BD-28 APPROVED: delivery points schema, unique constraints, modalities and referential integrity validated.';
END;
$$;

ROLLBACK;
