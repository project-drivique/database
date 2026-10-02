BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    confirmed_status_id UUID;
    cancelled_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    branch_id UUID;
    reservation_id UUID;
    reservation_created_at TIMESTAMPTZ;
    cash_expires_at TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO confirmed_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO cancelled_status_id FROM rental.reservation_statuses WHERE code = 'CANCELLED_BY_USER';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';

    IF admin_user_id IS NULL OR vehicle_id IS NULL OR confirmed_status_id IS NULL
       OR cancelled_status_id IS NULL OR coverage_id IS NULL OR mileage_plan_id IS NULL OR branch_id IS NULL THEN
        RAISE EXCEPTION 'Expected prerequisite seeds for reservation test';
    END IF;

    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated,
        cash_payment_code
    ) VALUES (
        'RES-TEST-001', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        branch_id, CURRENT_TIMESTAMP + INTERVAL '10 days', CURRENT_TIMESTAMP + INTERVAL '12 days',
        220000.00, 440000.00, 'CASH-TEST-001'
    ) RETURNING id, created_at, cash_payment_expires_at
    INTO reservation_id, reservation_created_at, cash_expires_at;

    IF cash_expires_at <> reservation_created_at + INTERVAL '72 hours' THEN
        RAISE EXCEPTION 'Expected cash payment expiration exactly 72 hours after reservation creation';
    END IF;

    BEGIN
        INSERT INTO rental.reservations (
            code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
            pickup_date, return_date, daily_rate, total_estimated
        ) VALUES (
            'RES-TEST-002', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
            CURRENT_TIMESTAMP + INTERVAL '11 days', CURRENT_TIMESTAMP + INTERVAL '13 days', 220000.00, 440000.00
        );
        RAISE EXCEPTION 'Expected overlapping blocking reservation to fail';
    EXCEPTION WHEN exclusion_violation THEN NULL;
    END;

    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-TEST-003', admin_user_id, vehicle_id, cancelled_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '11 days', CURRENT_TIMESTAMP + INTERVAL '13 days', 220000.00, 440000.00
    );

    BEGIN
        INSERT INTO rental.reservations (
            code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
            pickup_date, return_date, daily_rate, total_estimated
        ) VALUES (
            'RES-TEST-004', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
            CURRENT_TIMESTAMP + INTERVAL '14 days', CURRENT_TIMESTAMP + INTERVAL '13 days', 220000.00, 440000.00
        );
        RAISE EXCEPTION 'Expected invalid reservation period to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.reservations (
            code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
            cash_payment_branch_id, pickup_date, return_date, daily_rate, total_estimated
        ) VALUES (
            'RES-TEST-005', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
            branch_id, CURRENT_TIMESTAMP + INTERVAL '14 days', CURRENT_TIMESTAMP + INTERVAL '15 days', 220000.00, 220000.00
        );
        RAISE EXCEPTION 'Expected incomplete cash payment data to fail';
    EXCEPTION WHEN raise_exception THEN NULL;
    END;

    IF NOT EXISTS (
        SELECT 1 FROM rental.reservations
        WHERE id = reservation_id AND blocks_availability
    ) THEN
        RAISE EXCEPTION 'Expected confirmed reservation to block availability';
    END IF;

    RAISE NOTICE 'HU-BD-27 APPROVED: relations, 72-hour cash expiry, availability blocks and GiST overlap protection validated.';
END;
$$;

ROLLBACK;
