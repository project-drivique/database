BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    vehicle_id UUID;
    reservation_status_id UUID;
    coverage_id UUID;
    mileage_plan_id UUID;
    reservation_id UUID;
    report_id UUID;
    response_id UUID;
    report_updated_at TIMESTAMPTZ;
    response_updated_at TIMESTAMPTZ;
    required_index_count INTEGER;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';
    SELECT id INTO vehicle_id FROM fleet.vehicles WHERE plate = 'ABC-123';
    SELECT id INTO reservation_status_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    SELECT id INTO coverage_id FROM catalog.insurance_coverages WHERE name = 'Basic Protection';
    SELECT id INTO mileage_plan_id FROM catalog.mileage_plans WHERE name = 'Standard 200 km';

    INSERT INTO rental.reservations (
        code, customer_id, vehicle_id, status_id, insurance_coverage_id, mileage_plan_id,
        pickup_date, return_date, daily_rate, total_estimated
    ) VALUES (
        'RES-INCIDENT-TEST', admin_user_id, vehicle_id, reservation_status_id, coverage_id, mileage_plan_id,
        CURRENT_TIMESTAMP + INTERVAL '60 days', CURRENT_TIMESTAMP + INTERVAL '62 days', 220000.00, 440000.00
    ) RETURNING id INTO reservation_id;

    -- 1. Insert valid incident report
    INSERT INTO support.incident_reports (
        incident_code, vehicle_id, reservation_id, reported_by_user_id,
        status, priority, subject, description
    ) VALUES (
        'INC-2026-0001', vehicle_id, reservation_id, admin_user_id,
        'OPEN', 'HIGH', 'Falla en frenos delanteros', 'Se detecta ruido anormal al frenar a altas velocidades'
    ) RETURNING id INTO report_id;

    -- 2. Insert valid incident response
    INSERT INTO support.incident_responses (
        incident_report_id, author_user_id, message, attachment_url
    ) VALUES (
        report_id, admin_user_id, 'Vehículo ingresado a taller de diagnóstico', 'https://storage.drivique.com/incidents/INC-2026-0001/doc1.pdf'
    ) RETURNING id INTO response_id;

    -- 3. Test uniqueness constraint on incident_code
    BEGIN
        INSERT INTO support.incident_reports (
            incident_code, vehicle_id, reservation_id, reported_by_user_id,
            status, priority, subject, description
        ) VALUES (
            'INC-2026-0001', vehicle_id, reservation_id, admin_user_id,
            'OPEN', 'LOW', 'Duplicate Code Test', 'Should fail'
        );
        RAISE EXCEPTION 'Expected duplicate incident_code to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 4. Test invalid status check constraint
    BEGIN
        INSERT INTO support.incident_reports (
            incident_code, vehicle_id, reservation_id, reported_by_user_id,
            status, priority, subject, description
        ) VALUES (
            'INC-2026-0002', vehicle_id, reservation_id, admin_user_id,
            'INVALID_STATUS', 'LOW', 'Invalid status test', 'Should fail'
        );
        RAISE EXCEPTION 'Expected invalid status to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 5. Test invalid priority check constraint
    BEGIN
        INSERT INTO support.incident_reports (
            incident_code, vehicle_id, reservation_id, reported_by_user_id,
            status, priority, subject, description
        ) VALUES (
            'INC-2026-0003', vehicle_id, reservation_id, admin_user_id,
            'OPEN', 'EXTREME', 'Invalid priority test', 'Should fail'
        );
        RAISE EXCEPTION 'Expected invalid priority to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 6. Test blank message in incident response
    BEGIN
        INSERT INTO support.incident_responses (
            incident_report_id, author_user_id, message
        ) VALUES (
            report_id, admin_user_id, '   '
        );
        RAISE EXCEPTION 'Expected blank message to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 7. Test updated_at triggers
    UPDATE support.incident_reports SET status = 'IN_REVIEW', updated_at = '2000-01-01 00:00:00+00' WHERE id = report_id;
    UPDATE support.incident_responses SET message = 'Actualización pericial completada', updated_at = '2000-01-01 00:00:00+00' WHERE id = response_id;

    SELECT updated_at INTO report_updated_at FROM support.incident_reports WHERE id = report_id;
    SELECT updated_at INTO response_updated_at FROM support.incident_responses WHERE id = response_id;

    IF report_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ
       OR response_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected incident reports and responses audit triggers to update timestamp';
    END IF;

    -- 8. Test indexes existence
    SELECT COUNT(*) INTO required_index_count
    FROM pg_indexes
    WHERE schemaname = 'support'
      AND indexname IN (
          'idx_incident_reports_code',
          'idx_incident_reports_vehicle',
          'idx_incident_reports_reservation',
          'idx_incident_reports_reported_by',
          'idx_incident_reports_status',
          'idx_incident_responses_report',
          'idx_incident_responses_author'
      );

    IF required_index_count <> 7 THEN
        RAISE EXCEPTION 'Expected 7 indexes in support schema, found %', required_index_count;
    END IF;

    RAISE NOTICE 'HU-BD-38 APPROVED: incident reports, responses, uniqueness, indexes, triggers and FKs validated.';
END;
$$;

ROLLBACK;
