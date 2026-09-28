BEGIN;

DO $$
DECLARE
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM iam.password_policies
        WHERE policy_name = 'DRIVIQUE_DEFAULT'
          AND min_length = 12
          AND require_uppercase
          AND require_number
          AND require_symbol
          AND password_history_limit = 5
          AND expiration_days = 90
          AND is_active
    ) THEN
        RAISE EXCEPTION 'Expected the active default password policy seed';
    END IF;

    IF (SELECT count(*) FROM iam.security_configurations) <> 5 THEN
        RAISE EXCEPTION 'Expected five standard security configuration seeds';
    END IF;

    BEGIN
        INSERT INTO iam.password_policies (
            policy_name, min_length, password_history_limit, expiration_days, is_active
        ) VALUES ('INVALID_LENGTH', 7, 0, 90, FALSE);
        RAISE EXCEPTION 'Expected password length below eight to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.password_policies (
            policy_name, min_length, password_history_limit, expiration_days, is_active
        ) VALUES ('SECOND_ACTIVE_POLICY', 12, 5, 90, TRUE);
        RAISE EXCEPTION 'Expected a second active password policy to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.security_configurations (config_key, config_value, description)
        VALUES ('invalid-key', '1', 'Invalid key format test.');
        RAISE EXCEPTION 'Expected an invalid configuration key to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO iam.security_configurations (config_key, config_value, description)
        VALUES ('MAX_LOGIN_ATTEMPTS', '6', 'Duplicate configuration key test.');
        RAISE EXCEPTION 'Expected duplicated configuration key to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    SELECT updated_at INTO initial_updated_at
    FROM iam.password_policies
    WHERE policy_name = 'DRIVIQUE_DEFAULT';

    UPDATE iam.password_policies
    SET updated_at = initial_updated_at - INTERVAL '1 day', expiration_days = 60
    WHERE policy_name = 'DRIVIQUE_DEFAULT';

    SELECT updated_at INTO updated_timestamp
    FROM iam.password_policies
    WHERE policy_name = 'DRIVIQUE_DEFAULT';

    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected password policy updated_at trigger to refresh the timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-05 APPROVED: security policies, configuration integrity and timestamps validated.';
END;
$$;

ROLLBACK;
