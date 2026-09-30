BEGIN;

DO $$
DECLARE
    admin_id UUID;
    code_id UUID;
    temp_user_id UUID;
BEGIN
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';
    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    -- 1. Insert 2FA verification code
    INSERT INTO iam.verification_codes (
        user_id,
        purpose,
        code_hash,
        expires_at
    ) VALUES (
        admin_id,
        'TWO_FACTOR_AUTH',
        'hash_2fa_code_123',
        CURRENT_TIMESTAMP + INTERVAL '10 minutes'
    ) RETURNING id INTO code_id;

    -- 2. Validate CHECK constraint on purpose
    BEGIN
        INSERT INTO iam.verification_codes (
            user_id,
            purpose,
            code_hash,
            expires_at
        ) VALUES (
            admin_id,
            'INVALID_PURPOSE',
            'hash_invalid',
            CURRENT_TIMESTAMP + INTERVAL '10 minutes'
        );
        RAISE EXCEPTION 'Expected check constraint violation for invalid purpose';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 3. Consume verification code
    UPDATE iam.verification_codes
    SET used_at = CURRENT_TIMESTAMP
    WHERE id = code_id;

    IF NOT EXISTS (SELECT 1 FROM iam.verification_codes WHERE id = code_id AND used_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Expected verification code to be marked as used';
    END IF;

    -- 4. Cascade delete test
    INSERT INTO iam.users (first_name, last_name, email, password_hash)
    VALUES ('Otp', 'Tester', 'otptester@drivique.com', 'hash')
    RETURNING id INTO temp_user_id;

    INSERT INTO iam.verification_codes (user_id, purpose, code_hash, expires_at)
    VALUES (temp_user_id, 'ACCOUNT_VERIFICATION', 'hash_temp', CURRENT_TIMESTAMP + INTERVAL '15 minutes');

    DELETE FROM iam.users WHERE id = temp_user_id;

    IF EXISTS (SELECT 1 FROM iam.verification_codes WHERE user_id = temp_user_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on verification_codes';
    END IF;

    RAISE NOTICE 'HU-BD-10 APPROVED: verification_codes purpose check, 2FA code, and cascade delete validated.';
END;
$$;

ROLLBACK;
