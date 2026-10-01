BEGIN;

DO $$
DECLARE
    v_id UUID;
    mt_id UUID;
    m_id UUID;
    m_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM fleet.maintenance_types) < 4 THEN
        RAISE EXCEPTION 'Expected at least 4 seeded maintenance types';
    END IF;

    SELECT id INTO v_id FROM fleet.vehicles WHERE plate = 'ABC-123' LIMIT 1;
    SELECT id INTO mt_id FROM fleet.maintenance_types WHERE code = 'PREVENTIVE' LIMIT 1;

    -- 1. Test duplicate maintenance_type code constraint
    BEGIN
        INSERT INTO fleet.maintenance_types (code, name)
        VALUES ('PREVENTIVE', 'Otro Preventivo');
        RAISE EXCEPTION 'Expected duplicate maintenance type code to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 2. Test invalid maintenance_type code check constraint
    BEGIN
        INSERT INTO fleet.maintenance_types (code, name)
        VALUES ('INVALID_CODE', 'Tipo Inválido');
        RAISE EXCEPTION 'Expected invalid code check to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 3. Test invalid dates check constraint (completed_date < scheduled_date)
    BEGIN
        INSERT INTO fleet.vehicle_maintenances (
            vehicle_id, maintenance_type_id, scheduled_date, completed_date, cost, description
        ) VALUES (
            v_id, mt_id, '2024-05-10', '2024-05-01', 100000.00, 'Invalid dates'
        );
        RAISE EXCEPTION 'Expected completed_date < scheduled_date check to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 4. Test negative cost check constraint
    BEGIN
        INSERT INTO fleet.vehicle_maintenances (
            vehicle_id, maintenance_type_id, scheduled_date, completed_date, cost, description
        ) VALUES (
            v_id, mt_id, '2024-05-10', '2024-05-11', -500.00, 'Negative cost'
        );
        RAISE EXCEPTION 'Expected negative cost check to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 5. Test trigger updated_at on vehicle_maintenances
    INSERT INTO fleet.vehicle_maintenances (
        vehicle_id, maintenance_type_id, scheduled_date, completed_date, cost, description
    ) VALUES (
        v_id, mt_id, '2024-06-01', '2024-06-02', 300000.00, 'Test trigger'
    ) RETURNING id, updated_at INTO m_id, m_updated_at;

    UPDATE fleet.vehicle_maintenances
    SET cost = 320000.00
    WHERE id = m_id;

    IF (SELECT updated_at FROM fleet.vehicle_maintenances WHERE id = m_id) < m_updated_at THEN
        RAISE EXCEPTION 'Trigger failed to maintain valid updated_at timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-22 maintenance tests completed successfully';
END $$;

ROLLBACK;
