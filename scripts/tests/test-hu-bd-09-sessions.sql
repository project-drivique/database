BEGIN;

DO $$
DECLARE
    admin_id UUID;
    temp_user_id UUID;
    session_id UUID;
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';
    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    -- 1. Insert valid user session
    INSERT INTO iam.user_sessions (
        user_id,
        refresh_token_hash,
        device_info,
        ip_address,
        user_agent,
        started_at,
        expires_at
    ) VALUES (
        admin_id,
        'hash_test_rf_1234567890',
        'Windows 11 / Chrome 120',
        '192.168.1.100',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP + INTERVAL '7 days'
    ) RETURNING id INTO session_id;

    -- 2. Validate UNIQUE constraint on refresh_token_hash
    BEGIN
        INSERT INTO iam.user_sessions (
            user_id,
            refresh_token_hash,
            started_at,
            expires_at
        ) VALUES (
            admin_id,
            'hash_test_rf_1234567890',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP + INTERVAL '7 days'
        );
        RAISE EXCEPTION 'Expected unique violation on duplicate refresh_token_hash';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 3. Validate CHECK constraint (expires_at > started_at)
    BEGIN
        INSERT INTO iam.user_sessions (
            user_id,
            refresh_token_hash,
            started_at,
            expires_at
        ) VALUES (
            admin_id,
            'hash_test_invalid_dates',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP - INTERVAL '1 hour'
        );
        RAISE EXCEPTION 'Expected check constraint violation for expires_at <= started_at';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 4. Validate cascade delete on user_sessions
    INSERT INTO iam.users (first_name, last_name, email, password_hash)
    VALUES ('Session', 'User', 'sessionuser@drivique.com', 'hash')
    RETURNING id INTO temp_user_id;

    INSERT INTO iam.user_sessions (
        user_id,
        refresh_token_hash,
        started_at,
        expires_at
    ) VALUES (
        temp_user_id,
        'hash_temp_user_session',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP + INTERVAL '1 day'
    );

    DELETE FROM iam.users WHERE id = temp_user_id;

    IF EXISTS (SELECT 1 FROM iam.user_sessions WHERE user_id = temp_user_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on user_sessions when user is deleted';
    END IF;

    -- 5. Validate updated_at trigger on user_sessions
    SELECT updated_at INTO initial_updated_at FROM iam.user_sessions WHERE id = session_id;
    UPDATE iam.user_sessions
    SET updated_at = initial_updated_at - INTERVAL '1 day', revoked_at = CURRENT_TIMESTAMP
    WHERE id = session_id;

    SELECT updated_at INTO updated_timestamp FROM iam.user_sessions WHERE id = session_id;
    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected user_sessions updated_at trigger to refresh timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-09 APPROVED: user_sessions DDL, unique constraints, date check, cascade delete, and triggers validated.';
END;
$$;

ROLLBACK;
