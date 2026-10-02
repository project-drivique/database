BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    confirmed_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    service_id UUID;
    service_id_2 UUID;
    promotion_id UUID;
    reservation_id UUID;
    reservation_id_2 UUID;
    fetched_daily_rate NUMERIC(12, 2);
    fetched_discount NUMERIC(12, 2);
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO confirmed_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO service_id FROM catalog.additional_services WHERE name = 'Baby Seat';
    SELECT id INTO service_id_2 FROM catalog.additional_services WHERE name = 'GPS Navigation';

    IF admin_user_id IS NULL OR vehicle_id IS NULL OR confirmed_status_id IS NULL
       OR coverage_id IS NULL OR mileage_plan_id IS NULL OR service_id IS NULL OR service_id_2 IS NULL THEN
        RAISE EXCEPTION 'Expected prerequisite seeds for reservation services and promotions test';
    END IF;

    -- 1. Create a test promotion
    INSERT INTO catalog.promotions (
        code, offer_type, discount_type, discount_value,
        starts_at, ends_at, minimum_rental_days, max_uses_limit
    ) VALUES (
        'PROMO-HU29-TEST', 'PROMOTION', 'FIXED_AMOUNT', 30000.00,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 1, 500
    ) RETURNING id INTO promotion_id;

    -- 2. Create test reservation 1
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-HU29-001', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '30 days', CURRENT_TIMESTAMP + INTERVAL '33 days',
        250000.00, 750000.00
    ) RETURNING id INTO reservation_id;

    -- 3. Insert additional service with frozen rate
    INSERT INTO rental.reservation_additional_services (
        reservation_id, additional_service_id, quantity, daily_rate
    ) VALUES (
        reservation_id, service_id, 2, 25000.00
    );

    SELECT daily_rate INTO fetched_daily_rate
    FROM rental.reservation_additional_services
    WHERE reservation_id = reservation_id AND additional_service_id = service_id;

    IF fetched_daily_rate <> 25000.00 THEN
        RAISE EXCEPTION 'Expected frozen daily rate to be 25000.00';
    END IF;

    -- 4. Insert reservation promotion with frozen discount
    INSERT INTO rental.reservation_promotions (
        reservation_id, promotion_id, discount_applied
    ) VALUES (
        reservation_id, promotion_id, 30000.00
    );

    SELECT discount_applied INTO fetched_discount
    FROM rental.reservation_promotions
    WHERE reservation_id = reservation_id AND promotion_id = promotion_id;

    IF fetched_discount <> 30000.00 THEN
        RAISE EXCEPTION 'Expected frozen discount to be 30000.00';
    END IF;

    -- 5. Test Composite PK violation on reservation_additional_services
    BEGIN
        INSERT INTO rental.reservation_additional_services (
            reservation_id, additional_service_id, quantity, daily_rate
        ) VALUES (
            reservation_id, service_id, 1, 25000.00
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate (reservation_id, additional_service_id)';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 6. Test Composite PK violation on reservation_promotions
    BEGIN
        INSERT INTO rental.reservation_promotions (
            reservation_id, promotion_id, discount_applied
        ) VALUES (
            reservation_id, promotion_id, 15000.00
        );
        RAISE EXCEPTION 'Expected unique violation for duplicate (reservation_id, promotion_id)';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 7. Test CHECK constraint: quantity > 0
    BEGIN
        INSERT INTO rental.reservation_additional_services (
            reservation_id, additional_service_id, quantity, daily_rate
        ) VALUES (
            reservation_id, service_id_2, 0, 18000.00
        );
        RAISE EXCEPTION 'Expected check violation for quantity <= 0';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 8. Test CHECK constraint: daily_rate >= 0
    BEGIN
        INSERT INTO rental.reservation_additional_services (
            reservation_id, additional_service_id, quantity, daily_rate
        ) VALUES (
            reservation_id, service_id_2, 1, -500.00
        );
        RAISE EXCEPTION 'Expected check violation for negative daily_rate';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 9. Test CHECK constraint: discount_applied >= 0
    BEGIN
        INSERT INTO rental.reservation_promotions (
            reservation_id, promotion_id, discount_applied
        ) VALUES (
            reservation_id, promotion_id, -1000.00
        );
        RAISE EXCEPTION 'Expected check violation for negative discount_applied';
    EXCEPTION WHEN check_violation OR unique_violation THEN NULL;
    END;

    -- 10. Test ON DELETE RESTRICT on catalog service / promotion
    BEGIN
        DELETE FROM catalog.additional_services WHERE id = service_id;
        RAISE EXCEPTION 'Expected foreign key restriction when deleting referenced additional service';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;

    BEGIN
        DELETE FROM catalog.promotions WHERE id = promotion_id;
        RAISE EXCEPTION 'Expected foreign key restriction when deleting referenced promotion';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;

    -- 11. Create reservation 2 and test ON DELETE CASCADE from reservation
    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-HU29-002', admin_user_id, vehicle_id, confirmed_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '35 days', CURRENT_TIMESTAMP + INTERVAL '38 days',
        250000.00, 750000.00
    ) RETURNING id INTO reservation_id_2;

    INSERT INTO rental.reservation_additional_services (
        reservation_id, additional_service_id, quantity, daily_rate
    ) VALUES (
        reservation_id_2, service_id, 1, 25000.00
    );

    INSERT INTO rental.reservation_promotions (
        reservation_id, promotion_id, discount_applied
    ) VALUES (
        reservation_id_2, promotion_id, 20000.00
    );

    DELETE FROM rental.reservations WHERE id = reservation_id_2;

    IF EXISTS (
        SELECT 1 FROM rental.reservation_additional_services
        WHERE reservation_id = reservation_id_2
    ) OR EXISTS (
        SELECT 1 FROM rental.reservation_promotions
        WHERE reservation_id = reservation_id_2
    ) THEN
        RAISE EXCEPTION 'Expected reservation services and promotions to be deleted when reservation is deleted';
    END IF;

    RAISE NOTICE 'HU-BD-29 APPROVED: reservation additional services and promotions composite keys, frozen rates, cascade and restrict rules validated.';
END;
$$;

ROLLBACK;
