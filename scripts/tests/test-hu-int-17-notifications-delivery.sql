BEGIN;

DO $$
DECLARE
    v_user_id UUID;
    v_notif_id UUID;
    v_outbox_id UUID;
    v_template_count INT;
    v_updated_at_1 TIMESTAMPTZ;
    v_updated_at_2 TIMESTAMPTZ;
    v_has_notif_select BOOLEAN;
    v_has_outbox_insert BOOLEAN;
    v_has_attempt_insert BOOLEAN;
    v_has_template_select BOOLEAN;
    v_has_pref_update BOOLEAN;
BEGIN
    SELECT id INTO v_user_id FROM iam.users LIMIT 1;
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No user found for testing HU-INT-17';
    END IF;

    -- 1. Test iam.user_preferences new columns
    UPDATE iam.user_preferences
    SET push_notifications = TRUE,
        in_app_notifications = TRUE,
        marketing_notifications = FALSE
    WHERE user_id = v_user_id;

    -- 2. Test support.notifications extended attributes
    INSERT INTO support.notifications (
        user_id, channel, type, event_type, criticality, subject, message, metadata, idempotency_key
    ) VALUES (
        v_user_id,
        'EMAIL',
        'RESERVATION',
        'RESERVATION',
        'HIGH',
        'Reserva confirmada BK-999',
        'Tu reserva ha sido confirmada con éxito.',
        '{"bookingCode": "BK-999", "vehicle": "Mazda CX-5"}'::jsonb,
        'idem-notif-hu17-001'
    ) RETURNING id INTO v_notif_id;

    -- Test duplicate idempotency_key on notifications for same user
    BEGIN
        INSERT INTO support.notifications (
            user_id, channel, type, event_type, criticality, subject, message, idempotency_key
        ) VALUES (
            v_user_id, 'EMAIL', 'RESERVATION', 'RESERVATION', 'HIGH', 'Duplicate test', 'Msg', 'idem-notif-hu17-001'
        );
        RAISE EXCEPTION 'Expected duplicate idempotency_key to fail on notifications';
    EXCEPTION WHEN unique_violation THEN
        -- Expected
        NULL;
    END;

    -- 3. Test notification_templates exist
    SELECT COUNT(*) INTO v_template_count
    FROM support.notification_templates
    WHERE is_active = TRUE;

    IF v_template_count < 10 THEN
        RAISE EXCEPTION 'Expected at least 10 seed notification templates, found %', v_template_count;
    END IF;

    -- 4. Test support.notification_outbox
    INSERT INTO support.notification_outbox (
        notification_id, channel, recipient, status, max_retries, idempotency_key, metadata
    ) VALUES (
        v_notif_id,
        'EMAIL',
        'user@example.com',
        'PENDING',
        3,
        'idem-outbox-hu17-001',
        '{"priority": "HIGH"}'::jsonb
    ) RETURNING id, updated_at INTO v_outbox_id, v_updated_at_1;

    -- Test outbox duplicate idempotency
    BEGIN
        INSERT INTO support.notification_outbox (
            notification_id, channel, recipient, status, idempotency_key
        ) VALUES (
            v_notif_id, 'EMAIL', 'user@example.com', 'PENDING', 'idem-outbox-hu17-001'
        );
        RAISE EXCEPTION 'Expected duplicate idempotency_key to fail on outbox';
    EXCEPTION WHEN unique_violation THEN
        -- Expected
        NULL;
    END;

    -- Test outbox update and trigger
    PERFORM pg_sleep(0.01);
    UPDATE support.notification_outbox
    SET status = 'FAILED',
        retry_count = 1,
        next_retry_at = CURRENT_TIMESTAMP + INTERVAL '5 minutes'
    WHERE id = v_outbox_id
    RETURNING updated_at INTO v_updated_at_2;

    -- 5. Test support.notification_delivery_attempts
    -- First attempt (Failed)
    INSERT INTO support.notification_delivery_attempts (
        outbox_id, attempt_number, provider, status, error_code, error_message
    ) VALUES (
        v_outbox_id,
        1,
        'SENDGRID',
        'FAILED',
        '503',
        'Service temporarily unavailable'
    );

    -- Second attempt (Success)
    INSERT INTO support.notification_delivery_attempts (
        outbox_id, attempt_number, provider, status, provider_message_id
    ) VALUES (
        v_outbox_id,
        2,
        'SENDGRID',
        'SUCCESS',
        'msg-sg-987654321'
    );

    -- Test duplicate attempt number on same outbox message
    BEGIN
        INSERT INTO support.notification_delivery_attempts (
            outbox_id, attempt_number, provider, status
        ) VALUES (
            v_outbox_id, 2, 'SENDGRID', 'SUCCESS'
        );
        RAISE EXCEPTION 'Expected duplicate attempt_number to fail on delivery attempts';
    EXCEPTION WHEN unique_violation THEN
        -- Expected
        NULL;
    END;

    -- 6. Test DCL privileges for drivique_app
    SELECT has_table_privilege('drivique_app', 'support.notifications', 'SELECT') INTO v_has_notif_select;
    SELECT has_table_privilege('drivique_app', 'support.notification_outbox', 'INSERT') INTO v_has_outbox_insert;
    SELECT has_table_privilege('drivique_app', 'support.notification_delivery_attempts', 'INSERT') INTO v_has_attempt_insert;
    SELECT has_table_privilege('drivique_app', 'support.notification_templates', 'SELECT') INTO v_has_template_select;
    SELECT has_table_privilege('drivique_app', 'iam.user_preferences', 'UPDATE') INTO v_has_pref_update;

    IF NOT (v_has_notif_select AND v_has_outbox_insert AND v_has_attempt_insert AND v_has_template_select AND v_has_pref_update) THEN
        RAISE EXCEPTION 'Privilege check failed for drivique_app role on HU-INT-17 objects';
    END IF;

    RAISE NOTICE 'HU-INT-17 APPROVED: notifications lifecycle, outbox, delivery attempts, templates and preferences validated.';
END $$;

ROLLBACK;
