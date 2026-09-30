BEGIN;

DO $$
DECLARE
    admin_id UUID;
    user_role_count INTEGER;
    temp_user_id UUID;
    temp_code_id UUID;
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    -- 1. Check admin user seed
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';
    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    -- 2. Check admin user role assignment
    SELECT count(*) INTO user_role_count
    FROM iam.user_roles ur
    JOIN iam.roles r ON ur.role_id = r.id
    WHERE ur.user_id = admin_id AND r.code = 'SUPER_ADMIN';

    IF user_role_count <> 1 THEN
        RAISE EXCEPTION 'Expected admin user to have SUPER_ADMIN role assigned';
    END IF;

    -- 3. Unique email constraint
    BEGIN
        INSERT INTO iam.users (first_name, last_name, email, document_number, password_hash)
        VALUES ('Duplicate', 'User', 'admin@drivique.com', '9999999999', 'hash123');
        RAISE EXCEPTION 'Expected duplicate email to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 4. Unique document_number constraint
    BEGIN
        INSERT INTO iam.users (first_name, last_name, email, document_number, password_hash)
        VALUES ('Duplicate', 'Doc', 'unique@drivique.com', '1000000000', 'hash123');
        RAISE EXCEPTION 'Expected duplicate document_number to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 5. Cascade delete user -> deletes user_profile, user_roles, verification_codes
    INSERT INTO iam.users (first_name, last_name, email, document_number, password_hash)
    VALUES ('Temp', 'User', 'temp@drivique.com', '8888888888', 'hash')
    RETURNING id INTO temp_user_id;

    INSERT INTO iam.user_profiles (user_id, address, city_of_residence)
    VALUES (temp_user_id, 'Calle 10 # 20-30', 'Bogota');

    INSERT INTO iam.user_roles (user_id, role_id)
    SELECT temp_user_id, r.id FROM iam.roles r WHERE r.code = 'CUSTOMER';

    INSERT INTO iam.verification_codes (user_id, purpose, code_hash, expires_at)
    VALUES (temp_user_id, 'ACCOUNT_VERIFICATION', 'dummy_hash', CURRENT_TIMESTAMP + INTERVAL '15 minutes')
    RETURNING id INTO temp_code_id;

    DELETE FROM iam.users WHERE id = temp_user_id;

    IF EXISTS (SELECT 1 FROM iam.user_profiles WHERE user_id = temp_user_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on user_profiles';
    END IF;
    IF EXISTS (SELECT 1 FROM iam.user_roles WHERE user_id = temp_user_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on user_roles';
    END IF;
    IF EXISTS (SELECT 1 FROM iam.verification_codes WHERE user_id = temp_user_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on verification_codes';
    END IF;

    -- 6. Trigger updated_at on users
    SELECT updated_at INTO initial_updated_at FROM iam.users WHERE id = admin_id;
    UPDATE iam.users SET updated_at = initial_updated_at - INTERVAL '1 day', phone = '+573001234567' WHERE id = admin_id;
    SELECT updated_at INTO updated_timestamp FROM iam.users WHERE id = admin_id;

    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected user updated_at trigger to refresh timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-07 APPROVED: users, profiles, user_roles and constraints validated.';
END;
$$;

ROLLBACK;
