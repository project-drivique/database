BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    reservation_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    branch_id UUID;
    reservation_id UUID;
    vehicle_rating_id UUID;
    branch_review_id UUID;
    vehicle_rating_updated_at TIMESTAMPTZ;
    branch_review_updated_at TIMESTAMPTZ;
    required_index_count INTEGER;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO reservation_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';

    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-RATING-TEST', admin_user_id, vehicle_id, reservation_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '50 days', CURRENT_TIMESTAMP + INTERVAL '52 days', 220000.00, 440000.00
    ) RETURNING id INTO reservation_id;

    INSERT INTO rental.vehicle_ratings (reservation_id, vehicle_id, user_id, rating, comment)
    VALUES (reservation_id, vehicle_id, admin_user_id, 5, 'Vehicle in excellent condition')
    RETURNING id INTO vehicle_rating_id;

    INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating, comment)
    VALUES (branch_id, admin_user_id, reservation_id, 4, 'Fast pickup process')
    RETURNING id INTO branch_review_id;

    BEGIN
        INSERT INTO rental.vehicle_ratings (reservation_id, vehicle_id, user_id, rating)
        VALUES (reservation_id, vehicle_id, admin_user_id, 4);
        RAISE EXCEPTION 'Expected duplicate vehicle rating for reservation to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating)
        VALUES (branch_id, admin_user_id, reservation_id, 4);
        RAISE EXCEPTION 'Expected duplicate branch review for reservation and branch to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.vehicle_ratings (reservation_id, vehicle_id, user_id, rating)
        VALUES (gen_random_uuid(), vehicle_id, admin_user_id, 0);
        RAISE EXCEPTION 'Expected invalid vehicle rating to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating)
        VALUES (branch_id, admin_user_id, reservation_id, 6);
        RAISE EXCEPTION 'Expected invalid branch rating to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    UPDATE rental.vehicle_ratings SET updated_at = '2000-01-01 00:00:00+00' WHERE id = vehicle_rating_id;
    UPDATE rental.branch_reviews SET updated_at = '2000-01-01 00:00:00+00' WHERE id = branch_review_id;

    SELECT updated_at INTO vehicle_rating_updated_at FROM rental.vehicle_ratings WHERE id = vehicle_rating_id;
    SELECT updated_at INTO branch_review_updated_at FROM rental.branch_reviews WHERE id = branch_review_id;

    IF vehicle_rating_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ
       OR branch_review_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected ratings and reviews audit triggers';
    END IF;

    SELECT COUNT(*) INTO required_index_count
    FROM pg_indexes
    WHERE schemaname = 'rental'
      AND indexname IN ('idx_vehicle_ratings_veh', 'idx_branch_reviews_branch');

    IF required_index_count <> 2 THEN
        RAISE EXCEPTION 'Expected vehicle and branch review indexes';
    END IF;

    RAISE NOTICE 'HU-BD-37 APPROVED: ratings, reviews, uniqueness, indexes and audit validated.';
END;
$$;

ROLLBACK;
