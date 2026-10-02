BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    confirmed_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    reservation_id UUID;
    reservation_id_2 UUID;
    request_id UUID;
    ext_status VARCHAR(20);
    ext_amount NUMERIC(12, 2);
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO confirmed_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';

    IF admin_user_id IS NULL OR vehicle_id IS NULL OR confirmed_status_id IS NULL
       OR coverage_id IS NULL OR mileage_plan_id IS NULL THEN
        RAISE EXCEPTION 'Expected prerequisite seeds for rental extension requests test';
    END IF;

    -- 1. Create test reservation 1
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-EXT-001', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '40 days', CURRENT_TIMESTAMP + INTERVAL '43 days',
        220000.00, 660000.00
    ) RETURNING id INTO reservation_id;

    -- 2. Insert PENDING extension request
    INSERT INTO rental.rental_extension_requests (
        reservation_id, requested_return_date, status, additional_amount
    ) VALUES (
        reservation_id, CURRENT_TIMESTAMP + INTERVAL '45 days', 'PENDING', 440000.00
    ) RETURNING id INTO request_id;

    SELECT status, additional_amount INTO ext_status, ext_amount
    FROM rental.rental_extension_requests
    WHERE id = request_id;

    IF ext_status <> 'PENDING' OR ext_amount <> 440000.00 THEN
        RAISE EXCEPTION 'Failed to create pending extension request';
    END IF;

    -- 3. Update extension request to APPROVED with reviewer
    UPDATE rental.rental_extension_requests
    SET status = 'APPROVED',
        reviewed_by = admin_user_id,
        reviewed_at = CURRENT_TIMESTAMP
    WHERE id = request_id;

    SELECT status INTO ext_status
    FROM rental.rental_extension_requests
    WHERE id = request_id;

    IF ext_status <> 'APPROVED' THEN
        RAISE EXCEPTION 'Failed to approve extension request';
    END IF;

    -- 4. Test REJECTED and CANCELLED statuses
    INSERT INTO rental.rental_extension_requests (
        reservation_id, requested_return_date, status, additional_amount, reviewed_by, reviewed_at
    ) VALUES (
        reservation_id, CURRENT_TIMESTAMP + INTERVAL '46 days', 'REJECTED', 660000.00, admin_user_id, CURRENT_TIMESTAMP
    );

    INSERT INTO rental.rental_extension_requests (
        reservation_id, requested_return_date, status, additional_amount
    ) VALUES (
        reservation_id, CURRENT_TIMESTAMP + INTERVAL '47 days', 'CANCELLED', 880000.00
    );

    -- 5. Test CHECK constraint: invalid status
    BEGIN
        INSERT INTO rental.rental_extension_requests (
            reservation_id, requested_return_date, status, additional_amount
        ) VALUES (
            reservation_id, CURRENT_TIMESTAMP + INTERVAL '48 days', 'UNKNOWN', 100000.00
        );
        RAISE EXCEPTION 'Expected check violation for invalid status';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 6. Test CHECK constraint: negative additional_amount
    BEGIN
        INSERT INTO rental.rental_extension_requests (
            reservation_id, requested_return_date, status, additional_amount
        ) VALUES (
            reservation_id, CURRENT_TIMESTAMP + INTERVAL '48 days', 'PENDING', -50000.00
        );
        RAISE EXCEPTION 'Expected check violation for negative additional_amount';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 7. Test foreign key violation on invalid reservation_id
    BEGIN
        INSERT INTO rental.rental_extension_requests (
            reservation_id, requested_return_date, status, additional_amount
        ) VALUES (
            '00000000-0000-0000-0000-000000000000', CURRENT_TIMESTAMP + INTERVAL '48 days', 'PENDING', 100000.00
        );
        RAISE EXCEPTION 'Expected foreign key violation for unknown reservation_id';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;

    -- 8. Test ON DELETE CASCADE on reservation
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-EXT-002', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '50 days', CURRENT_TIMESTAMP + INTERVAL '52 days',
        220000.00, 440000.00
    ) RETURNING id INTO reservation_id_2;

    INSERT INTO rental.rental_extension_requests (
        reservation_id, requested_return_date, status, additional_amount
    ) VALUES (
        reservation_id_2, CURRENT_TIMESTAMP + INTERVAL '54 days', 'PENDING', 440000.00
    );

    DELETE FROM rental.reservations WHERE id = reservation_id_2;

    IF EXISTS (
        SELECT 1 FROM rental.rental_extension_requests
        WHERE reservation_id = reservation_id_2
    ) THEN
        RAISE EXCEPTION 'Expected extension requests to be deleted when reservation is deleted';
    END IF;

    RAISE NOTICE 'HU-BD-30 APPROVED: rental extension requests schema, check constraints, foreign keys and cascade delete validated.';
END;
$$;

ROLLBACK;
