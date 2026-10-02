BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    report_type_id UUID;
    generated_report_id UUID;
    type_updated_at TIMESTAMPTZ;
    report_updated_at TIMESTAMPTZ;
    seed_count INTEGER;
    required_index_count INTEGER;
    jsonb_query_count INTEGER;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';

    -- 1. Validate seeds
    SELECT COUNT(*) INTO seed_count
    FROM audit.administrative_report_types
    WHERE code IN ('FLEET_OCCUPANCY', 'REVENUE_SUMMARY', 'AUDIT_TRAIL', 'MAINTENANCE');

    IF seed_count <> 4 THEN
        RAISE EXCEPTION 'Expected 4 seeded administrative report types, found %', seed_count;
    END IF;

    SELECT id INTO report_type_id
    FROM audit.administrative_report_types
    WHERE code = 'FLEET_OCCUPANCY';

    -- 2. Insert valid generated report with JSONB filters
    INSERT INTO audit.generated_reports (
        report_type_id, format, generated_by, filters, file_url, status
    ) VALUES (
        report_type_id, 'PDF', admin_user_id,
        '{"branchId": "e1f1816e-a4ad-4c4f-9e6e-2a9c4033b001", "startDate": "2026-01-01", "endDate": "2026-01-31", "includeMaintenance": true}'::jsonb,
        'https://storage.drivique.com/reports/fleet-occupancy-202601.pdf', 'COMPLETED'
    ) RETURNING id INTO generated_report_id;

    -- 3. Insert valid report with EXCEL format
    INSERT INTO audit.generated_reports (
        report_type_id, format, generated_by, filters, file_url, status
    ) VALUES (
        report_type_id, 'EXCEL', admin_user_id,
        '{"branchId": "e1f1816e-a4ad-4c4f-9e6e-2a9c4033b001"}'::jsonb,
        'https://storage.drivique.com/reports/fleet-occupancy-202601.xlsx', 'COMPLETED'
    );

    -- 4. Test duplicate code on report types
    BEGIN
        INSERT INTO audit.administrative_report_types (code, name)
        VALUES ('FLEET_OCCUPANCY', 'Duplicate Report Type');
        RAISE EXCEPTION 'Expected duplicate report type code to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    -- 5. Test invalid format check constraint
    BEGIN
        INSERT INTO audit.generated_reports (
            report_type_id, format, generated_by, filters
        ) VALUES (
            report_type_id, 'XML', admin_user_id, '{}'::jsonb
        );
        RAISE EXCEPTION 'Expected invalid format XML to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    -- 6. Test updated_at triggers
    UPDATE audit.administrative_report_types
    SET description = 'Descripción actualizada', updated_at = '2000-01-01 00:00:00+00'
    WHERE id = report_type_id;

    UPDATE audit.generated_reports
    SET status = 'COMPLETED', updated_at = '2000-01-01 00:00:00+00'
    WHERE id = generated_report_id;

    SELECT updated_at INTO type_updated_at FROM audit.administrative_report_types WHERE id = report_type_id;
    SELECT updated_at INTO report_updated_at FROM audit.generated_reports WHERE id = generated_report_id;

    IF type_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ
       OR report_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected administrative reports updated_at triggers to execute';
    END IF;

    -- 7. Test JSONB query using GIN index operator
    SELECT COUNT(*) INTO jsonb_query_count
    FROM audit.generated_reports
    WHERE filters @> '{"branchId": "e1f1816e-a4ad-4c4f-9e6e-2a9c4033b001"}'::jsonb;

    IF jsonb_query_count <> 2 THEN
        RAISE EXCEPTION 'Expected 2 reports matching JSONB filter, found %', jsonb_query_count;
    END IF;

    -- 8. Test indexes existence
    SELECT COUNT(*) INTO required_index_count
    FROM pg_indexes
    WHERE schemaname = 'audit'
      AND indexname IN (
          'idx_administrative_report_types_code',
          'idx_generated_reports_type',
          'idx_generated_reports_generated_by',
          'idx_generated_reports_format',
          'idx_generated_reports_generated_at',
          'idx_generated_reports_filters'
      );

    IF required_index_count <> 6 THEN
        RAISE EXCEPTION 'Expected 6 indexes in audit schema, found %', required_index_count;
    END IF;

    RAISE NOTICE 'HU-BD-40 APPROVED: report types, generated reports, JSONB filters, indexes, triggers and seeds validated.';
END;
$$;

ROLLBACK;
