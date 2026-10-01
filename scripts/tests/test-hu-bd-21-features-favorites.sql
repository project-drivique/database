BEGIN;

DO $$
DECLARE
    v_id UUID;
    u_id UUID;
    f_id UUID;
BEGIN
    IF (SELECT COUNT(*) FROM fleet.features) < 10 THEN
        RAISE EXCEPTION 'Expected at least 10 seeded features';
    END IF;

    SELECT id INTO v_id FROM fleet.vehicles WHERE plate = 'ABC-123' LIMIT 1;
    SELECT id INTO f_id FROM fleet.features WHERE name = 'Aire Acondicionado' LIMIT 1;
    SELECT id INTO u_id FROM iam.users LIMIT 1;

    -- If no user exists, create a temporary one for testing favorites
    IF u_id IS NULL THEN
        INSERT INTO iam.users (email, password_hash, first_name, last_name, phone)
        VALUES ('test-fav-user@drivique.com', '$2a$12$hashedpasswordplaceholder', 'Test', 'User', '3009998877')
        RETURNING id INTO u_id;
    END IF;

    -- 1. Test duplicate feature name constraint
    BEGIN
        INSERT INTO fleet.features (name, feature_group, is_active)
        VALUES ('Aire Acondicionado', 'COMFORT', TRUE);
        RAISE EXCEPTION 'Expected duplicate feature name to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 2. Test invalid feature group check constraint
    BEGIN
        INSERT INTO fleet.features (name, feature_group, is_active)
        VALUES ('Super Feature', 'INVALID_GROUP', TRUE);
        RAISE EXCEPTION 'Expected invalid feature_group check to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 3. Test composite PK on vehicle_features
    BEGIN
        INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
        VALUES (v_id, f_id);
        -- ABC-123 already has 'Aire Acondicionado' from seeds
        RAISE EXCEPTION 'Expected duplicate vehicle_features composite PK to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 4. Test user_favorite_vehicles composite PK
    INSERT INTO fleet.user_favorite_vehicles (user_id, vehicle_id)
    VALUES (u_id, v_id);

    BEGIN
        INSERT INTO fleet.user_favorite_vehicles (user_id, vehicle_id)
        VALUES (u_id, v_id);
        RAISE EXCEPTION 'Expected duplicate user_favorite_vehicles PK to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 5. Test cascade delete on vehicle
    DELETE FROM fleet.user_favorite_vehicles WHERE user_id = u_id AND vehicle_id = v_id;

    RAISE NOTICE 'HU-BD-21 features and favorites tests completed successfully';
END $$;

ROLLBACK;
