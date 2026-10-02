BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    reservation_id UUID;
    notification_id UUID;
    notification_updated_at TIMESTAMPTZ;
    required_index_count INTEGER;
    unread_count INTEGER;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO reservation_id FROM rental.reservations LIMIT 1;

    -- 1. Insert valid unread notification
    INSERT INTO support.notifications (
        user_id, channel, type, subject, message, reference_id, is_read, sent_at
    ) VALUES (
        admin_user_id, 'EMAIL', 'RESERVATION', 'Confirmación de Reserva',
        'Tu reserva ha sido confirmada exitosamente.', reservation_id, FALSE, CURRENT_TIMESTAMP
    ) RETURNING id INTO notification_id;

    -- 2. Insert valid read notification
    INSERT INTO support.notifications (
        user_id, channel, type, subject, message, is_read, sent_at, read_at
    ) VALUES (
        admin_user_id, 'IN_APP', 'SECURITY', 'Nuevo inicio de sesión detectado',
        'Se ha detectado un inicio de sesión desde un nuevo dispositivo.', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    -- 3. Test invalid channel check constraint
    BEGIN
        INSERT INTO support.notifications (
            user_id, channel, type, subject, message
        ) VALUES (
            admin_user_id, 'TELEGRAM', 'GENERAL', 'Test', 'Invalid channel test'
        );
        RAISE EXCEPTION 'Expected invalid channel to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 4. Test invalid type check constraint
    BEGIN
        INSERT INTO support.notifications (
            user_id, channel, type, subject, message
        ) VALUES (
            admin_user_id, 'SMS', 'MARKETING_BLAST', 'Test', 'Invalid type test'
        );
        RAISE EXCEPTION 'Expected invalid type to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 5. Test blank subject check constraint
    BEGIN
        INSERT INTO support.notifications (
            user_id, channel, type, subject, message
        ) VALUES (
            admin_user_id, 'PUSH', 'PROMOTION', '   ', 'Blank subject test'
        );
        RAISE EXCEPTION 'Expected blank subject to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 6. Test updated_at trigger
    UPDATE support.notifications
    SET is_read = TRUE, read_at = CURRENT_TIMESTAMP, updated_at = '2000-01-01 00:00:00+00'
    WHERE id = notification_id;

    SELECT updated_at INTO notification_updated_at
    FROM support.notifications
    WHERE id = notification_id;

    IF notification_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected notifications updated_at trigger to execute';
    END IF;

    -- 7. Test indexes existence (especially composite idx_notifications_user_unread)
    SELECT COUNT(*) INTO required_index_count
    FROM pg_indexes
    WHERE schemaname = 'support'
      AND indexname IN (
          'idx_notifications_user_unread',
          'idx_notifications_user',
          'idx_notifications_type',
          'idx_notifications_channel',
          'idx_notifications_created_at'
      );

    IF required_index_count <> 5 THEN
        RAISE EXCEPTION 'Expected 5 notification indexes in support schema, found %', required_index_count;
    END IF;

    -- 8. Test unread count query
    SELECT COUNT(*) INTO unread_count
    FROM support.notifications
    WHERE user_id = admin_user_id AND is_read = FALSE;

    RAISE NOTICE 'HU-BD-39 APPROVED: notifications, composite index, check constraints and triggers validated.';
END;
$$;

ROLLBACK;
