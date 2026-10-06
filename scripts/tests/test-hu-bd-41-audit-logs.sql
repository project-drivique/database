BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    branch_id UUID;
    vehicle_id UUID;
    audit_log_id UUID;
    required_index_count INTEGER;
    jsonb_query_count INTEGER;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO branch_id FROM location.branches WHERE name = 'Drivique Bogotá Centro';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';

    -- 1. Insert valid audit log with old_data, new_data and INET ip_address
    INSERT INTO audit.audit_logs (
        domain_name, entity_name, entity_id, operation, result,
        actor_user_id, branch_id, ip_address, description,
        old_data, new_data
    ) VALUES (
        'rental', 'reservations', vehicle_id, 'UPDATE', 'SUCCESS',
        admin_user_id, branch_id, '192.168.1.150'::inet, 'Cambio de estado de reserva a CONFIRMED',
        '{"status": "PENDING_PAYMENT", "total": 440000.00}'::jsonb,
        '{"status": "CONFIRMED", "total": 440000.00, "confirmedBy": "admin"}'::jsonb
    ) RETURNING id INTO audit_log_id;

    -- 2. Insert valid audit log for failed delete operation
    INSERT INTO audit.audit_logs (
        domain_name, entity_name, entity_id, operation, result,
        actor_user_id, branch_id, ip_address, description,
        old_data, new_data
    ) VALUES (
        'fleet', 'vehicles', vehicle_id, 'DELETE', 'FAILURE',
        admin_user_id, branch_id, '10.0.0.1'::inet, 'Intento de eliminar vehículo con reservas activas bloqueado por FK',
        '{"plate": "ABC-123", "status": "AVAILABLE"}'::jsonb,
        null
    );

    -- 3. Test invalid operation check constraint
    BEGIN
        INSERT INTO audit.audit_logs (
            domain_name, entity_name, operation, result, actor_user_id
        ) VALUES (
            'rental', 'reservations', 'PURGE', 'SUCCESS', admin_user_id
        );
        RAISE EXCEPTION 'Expected invalid operation PURGE to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 4. Test invalid result check constraint
    BEGIN
        INSERT INTO audit.audit_logs (
            domain_name, entity_name, operation, result, actor_user_id
        ) VALUES (
            'rental', 'reservations', 'INSERT', 'WARN', admin_user_id
        );
        RAISE EXCEPTION 'Expected invalid result WARN to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 5. Test blank domain_name check constraint
    BEGIN
        INSERT INTO audit.audit_logs (
            domain_name, entity_name, operation, result, actor_user_id
        ) VALUES (
            '   ', 'reservations', 'INSERT', 'SUCCESS', admin_user_id
        );
        RAISE EXCEPTION 'Expected blank domain_name to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 6. Test JSONB querying with GIN index operator
    SELECT COUNT(*) INTO jsonb_query_count
    FROM audit.audit_logs
    WHERE new_data @> '{"status": "CONFIRMED"}'::jsonb;

    IF jsonb_query_count <> 1 THEN
        RAISE EXCEPTION 'Expected 1 audit log matching JSONB snapshot, found %', jsonb_query_count;
    END IF;

    -- 7. Test indexes existence (especially idx_audit_table_date and idx_audit_actor)
    SELECT COUNT(*) INTO required_index_count
    FROM pg_indexes
    WHERE schemaname = 'audit'
      AND indexname IN (
          'idx_audit_table_date',
          'idx_audit_actor',
          'idx_audit_logs_domain',
          'idx_audit_logs_entity_id',
          'idx_audit_logs_branch',
          'idx_audit_logs_operation',
          'idx_audit_logs_old_data',
          'idx_audit_logs_new_data'
      );

    IF required_index_count <> 8 THEN
        RAISE EXCEPTION 'Expected 8 audit_logs indexes in audit schema, found %', required_index_count;
    END IF;

    RAISE NOTICE 'HU-BD-41 APPROVED: audit_logs, INET IP persistence, JSONB snapshots, indexes, FKs and checks validated.';
END;
$$;

ROLLBACK;
