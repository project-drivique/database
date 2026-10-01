BEGIN;

DO $$
DECLARE
    admin_id UUID;
    lang_id UUID;
    curr_id UUID;
    temp_user_id UUID;
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_id FROM iam.users WHERE email = 'admin@drivique.com';
    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    SELECT id INTO lang_id FROM core.languages WHERE is_default = true LIMIT 1;
    SELECT id INTO curr_id FROM core.currencies WHERE is_default = true LIMIT 1;

    -- 1. Insert default preferences for admin
    INSERT INTO iam.user_preferences (user_id, language_id, currency_id, theme_preference)
    VALUES (admin_id, lang_id, curr_id, 'DARK')
    ON CONFLICT (user_id) DO UPDATE SET theme_preference = 'DARK';

    INSERT INTO iam.users (first_name, last_name, email, password_hash)
    VALUES ('Theme', 'Test', 'themetest@drivique.com', 'hash')
    RETURNING id INTO temp_user_id;

    -- 2. Validate CHECK constraint on theme_preference
    BEGIN
        INSERT INTO iam.user_preferences (user_id, theme_preference)
        VALUES (temp_user_id, 'INVALID_THEME');

        RAISE EXCEPTION 'Expected check constraint violation for invalid theme';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 3. Validate cascade delete on user_preferences when user is deleted
    INSERT INTO iam.user_preferences (user_id, language_id, currency_id, theme_preference, email_notifications, sms_notifications)
    VALUES (temp_user_id, lang_id, curr_id, 'LIGHT', false, false);

    DELETE FROM iam.users WHERE id = temp_user_id;

    IF EXISTS (SELECT 1 FROM iam.user_preferences WHERE user_id = temp_user_id) THEN
        RAISE EXCEPTION 'Expected cascade delete on user_preferences when user is deleted';
    END IF;

    -- 4. Validate updated_at trigger on user_preferences
    SELECT updated_at INTO initial_updated_at FROM iam.user_preferences WHERE user_id = admin_id;
    UPDATE iam.user_preferences
    SET updated_at = initial_updated_at - INTERVAL '1 day', theme_preference = 'LIGHT'
    WHERE user_id = admin_id;

    SELECT updated_at INTO updated_timestamp FROM iam.user_preferences WHERE user_id = admin_id;
    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected user_preferences updated_at trigger to refresh timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-08 APPROVED: user_preferences DDL, constraints, cascade delete, and triggers validated.';
END;
$$;

ROLLBACK;
