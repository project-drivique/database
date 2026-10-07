-- ==============================================================================
-- Test Script: HU-INT-10 - Favoritos y reseñas persistentes
-- Valida: permisos mínimos de drivique_app, duplicados, contenido inválido,
-- recursos eliminados (cascade) y operación real con el rol de la aplicación.
-- ==============================================================================

BEGIN;

-- 1. Permisos mínimos del rol de aplicación (ejecutado como migrador)
DO $$
BEGIN
    ASSERT has_table_privilege('drivique_app', 'fleet.user_favorite_vehicles', 'SELECT'), 'drivique_app must SELECT favorites';
    ASSERT has_table_privilege('drivique_app', 'fleet.user_favorite_vehicles', 'INSERT'), 'drivique_app must INSERT favorites';
    ASSERT has_table_privilege('drivique_app', 'fleet.user_favorite_vehicles', 'DELETE'), 'drivique_app must DELETE favorites';
    ASSERT NOT has_table_privilege('drivique_app', 'fleet.user_favorite_vehicles', 'UPDATE'), 'drivique_app must not UPDATE favorites';

    ASSERT has_schema_privilege('drivique_app', 'rental', 'USAGE'), 'drivique_app must use rental schema';
    ASSERT has_table_privilege('drivique_app', 'rental.vehicle_ratings', 'SELECT'), 'drivique_app must SELECT vehicle ratings';
    ASSERT has_table_privilege('drivique_app', 'rental.vehicle_ratings', 'INSERT'), 'drivique_app must INSERT vehicle ratings';
    ASSERT has_table_privilege('drivique_app', 'rental.branch_reviews', 'SELECT'), 'drivique_app must SELECT branch reviews';
    ASSERT has_table_privilege('drivique_app', 'rental.branch_reviews', 'INSERT'), 'drivique_app must INSERT branch reviews';
    ASSERT has_table_privilege('drivique_app', 'rental.reservations', 'SELECT'), 'drivique_app must SELECT reservations for eligibility';
    ASSERT has_table_privilege('drivique_app', 'rental.reservation_statuses', 'SELECT'), 'drivique_app must SELECT reservation statuses';
    ASSERT has_table_privilege('drivique_app', 'rental.reservation_delivery_points', 'SELECT'), 'drivique_app must SELECT delivery points';

    -- Mínimo privilegio: reseñas inmutables para la app y sin escritura de reservas en esta HU
    ASSERT NOT has_table_privilege('drivique_app', 'rental.vehicle_ratings', 'UPDATE'), 'drivique_app must not UPDATE vehicle ratings';
    ASSERT NOT has_table_privilege('drivique_app', 'rental.vehicle_ratings', 'DELETE'), 'drivique_app must not DELETE vehicle ratings';
    ASSERT NOT has_table_privilege('drivique_app', 'rental.branch_reviews', 'UPDATE'), 'drivique_app must not UPDATE branch reviews';
    ASSERT NOT has_table_privilege('drivique_app', 'rental.branch_reviews', 'DELETE'), 'drivique_app must not DELETE branch reviews';

    -- Recursos eliminados: favoritos se limpian si se elimina usuario o vehículo
    ASSERT (
        SELECT COUNT(*) FROM pg_constraint
        WHERE conrelid = 'fleet.user_favorite_vehicles'::regclass
          AND contype = 'f'
          AND confdeltype = 'c'
    ) = 2, 'Favorites must cascade when user or vehicle is deleted';

    -- Reseñas atadas obligatoriamente a una reserva
    ASSERT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'rental' AND table_name = 'vehicle_ratings'
          AND column_name = 'reservation_id' AND is_nullable = 'NO'
    ), 'Vehicle ratings must require a reservation';
    ASSERT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'rental' AND table_name = 'branch_reviews'
          AND column_name = 'reservation_id' AND is_nullable = 'NO'
    ), 'Branch reviews must require a reservation';

    ASSERT EXISTS (SELECT 1 FROM rental.reservation_statuses WHERE code = 'COMPLETED'),
        'COMPLETED reservation status is required for review eligibility';
END $$;

-- 2. Datos de prueba: cliente con una reserva COMPLETED (ejecutado como migrador)
DO $$
DECLARE
    v_customer_id UUID;
    v_vehicle_id UUID;
    v_branch_id UUID;
    v_status_id UUID;
    v_coverage_id UUID;
    v_plan_id UUID;
    v_reservation_id UUID;
BEGIN
    SELECT id INTO v_vehicle_id FROM fleet.vehicles LIMIT 1;
    SELECT id INTO v_branch_id FROM location.branches LIMIT 1;
    SELECT id INTO v_status_id FROM rental.reservation_statuses WHERE code = 'COMPLETED';
    SELECT id INTO v_coverage_id FROM catalog.insurance_coverages LIMIT 1;
    SELECT id INTO v_plan_id FROM catalog.mileage_plans LIMIT 1;

    ASSERT v_vehicle_id IS NOT NULL, 'Seed vehicle required';
    ASSERT v_branch_id IS NOT NULL, 'Seed branch required';
    ASSERT v_coverage_id IS NOT NULL, 'Seed insurance coverage required';
    ASSERT v_plan_id IS NOT NULL, 'Seed mileage plan required';

    INSERT INTO iam.users (first_name, last_name, email, password_hash, account_status, is_profile_complete)
    VALUES ('Review', 'Customer', 'test.hu-int-10@drivique.com', '$2a$12$e8r0.hash', 'ACTIVE', TRUE)
    RETURNING id INTO v_customer_id;

    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-HU-INT-10-TEST', v_customer_id, v_vehicle_id, v_status_id, v_coverage_id, v_plan_id,
        CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '8 days', 200000.00, 400000.00
    ) RETURNING id INTO v_reservation_id;

    PERFORM set_config('hu10.customer_id', v_customer_id::text, true);
    PERFORM set_config('hu10.vehicle_id', v_vehicle_id::text, true);
    PERFORM set_config('hu10.branch_id', v_branch_id::text, true);
    PERFORM set_config('hu10.reservation_id', v_reservation_id::text, true);
END $$;

-- 3. Operación real con el rol de la aplicación
SET LOCAL ROLE drivique_app;

DO $$
DECLARE
    v_customer_id UUID := current_setting('hu10.customer_id')::uuid;
    v_vehicle_id UUID := current_setting('hu10.vehicle_id')::uuid;
    v_branch_id UUID := current_setting('hu10.branch_id')::uuid;
    v_reservation_id UUID := current_setting('hu10.reservation_id')::uuid;
    v_status_code TEXT;
    v_count INTEGER;
    v_average NUMERIC;
BEGIN
    -- Favoritos: agregar, duplicado, listar, quitar
    INSERT INTO fleet.user_favorite_vehicles (user_id, vehicle_id) VALUES (v_customer_id, v_vehicle_id);

    BEGIN
        INSERT INTO fleet.user_favorite_vehicles (user_id, vehicle_id) VALUES (v_customer_id, v_vehicle_id);
        RAISE EXCEPTION 'Expected duplicate favorite to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    SELECT COUNT(*) INTO v_count FROM fleet.user_favorite_vehicles WHERE user_id = v_customer_id;
    ASSERT v_count = 1, 'Expected exactly one persisted favorite';

    DELETE FROM fleet.user_favorite_vehicles WHERE user_id = v_customer_id AND vehicle_id = v_vehicle_id;
    SELECT COUNT(*) INTO v_count FROM fleet.user_favorite_vehicles WHERE user_id = v_customer_id;
    ASSERT v_count = 0, 'Expected favorite to be removed';

    -- Elegibilidad: la app puede leer el estado de la reserva
    SELECT s.code INTO v_status_code
    FROM rental.reservations r
    JOIN rental.reservation_statuses s ON s.id = r.status_id
    WHERE r.id = v_reservation_id AND r.customer_id = v_customer_id;
    ASSERT v_status_code = 'COMPLETED', 'App role must read reservation status for eligibility';

    -- Reseña de vehículo: válida, duplicada, rating inválido, comentario vacío
    INSERT INTO rental.vehicle_ratings (reservation_id, vehicle_id, user_id, rating, comment)
    VALUES (v_reservation_id, v_vehicle_id, v_customer_id, 5, 'Excellent vehicle');

    BEGIN
        INSERT INTO rental.vehicle_ratings (reservation_id, vehicle_id, user_id, rating)
        VALUES (v_reservation_id, v_vehicle_id, v_customer_id, 4);
        RAISE EXCEPTION 'Expected duplicate vehicle rating to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.vehicle_ratings (reservation_id, vehicle_id, user_id, rating)
        VALUES (v_reservation_id, v_vehicle_id, v_customer_id, 6);
        RAISE EXCEPTION 'Expected rating 6 to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating, comment)
        VALUES (v_branch_id, v_customer_id, v_reservation_id, 4, '   ');
        RAISE EXCEPTION 'Expected blank comment to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating)
        VALUES (v_branch_id, v_customer_id, v_reservation_id, 0);
        RAISE EXCEPTION 'Expected rating 0 to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- Reseña de sede: válida y duplicada
    INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating, comment)
    VALUES (v_branch_id, v_customer_id, v_reservation_id, 4, 'Fast pickup');

    BEGIN
        INSERT INTO rental.branch_reviews (branch_id, user_id, reservation_id, rating)
        VALUES (v_branch_id, v_customer_id, v_reservation_id, 3);
        RAISE EXCEPTION 'Expected duplicate branch review to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- Métricas desde datos persistidos
    SELECT AVG(rating), COUNT(*) INTO v_average, v_count
    FROM rental.vehicle_ratings WHERE user_id = v_customer_id;
    ASSERT v_count = 1 AND v_average = 5, 'Vehicle rating metrics must come from persisted data';

    SELECT AVG(rating), COUNT(*) INTO v_average, v_count
    FROM rental.branch_reviews WHERE user_id = v_customer_id;
    ASSERT v_count = 1 AND v_average = 4, 'Branch review metrics must come from persisted data';

    -- Mínimo privilegio en ejecución real
    BEGIN
        UPDATE rental.vehicle_ratings SET rating = 1 WHERE user_id = v_customer_id;
        RAISE EXCEPTION 'Expected app role to be unable to edit ratings';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;

    BEGIN
        DELETE FROM rental.branch_reviews WHERE user_id = v_customer_id;
        RAISE EXCEPTION 'Expected app role to be unable to delete reviews';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;

    RAISE NOTICE 'HU-INT-10 APPROVED: grants, favorites, verified reviews, duplicates, invalid content and metrics validated.';
END $$;

RESET ROLE;

ROLLBACK;
