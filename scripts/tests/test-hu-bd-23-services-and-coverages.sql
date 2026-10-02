BEGIN;

DO $$
DECLARE
    service_id UUID;
    service_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM catalog.additional_services) <> 5
       OR NOT EXISTS (SELECT 1 FROM catalog.additional_services WHERE name = 'Baby Seat')
       OR NOT EXISTS (SELECT 1 FROM catalog.additional_services WHERE name = 'Mobile Wi-Fi') THEN
        RAISE EXCEPTION 'Expected additional service seeds';
    END IF;

    IF (SELECT COUNT(*) FROM catalog.insurance_coverages) <> 3
       OR NOT EXISTS (
           SELECT 1 FROM catalog.insurance_coverages
           WHERE name = 'Basic Protection' AND daily_rate = 0
       )
       OR NOT EXISTS (
           SELECT 1 FROM catalog.insurance_coverages
           WHERE name = 'Premium Protection' AND daily_rate > 0
       ) THEN
        RAISE EXCEPTION 'Expected insurance coverage seeds';
    END IF;

    BEGIN
        INSERT INTO catalog.additional_services (name, daily_rate)
        VALUES ('Baby Seat', 10000.00);
        RAISE EXCEPTION 'Expected duplicate additional service name to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.insurance_coverages (name, daily_rate, description)
        VALUES ('Invalid coverage', -1.00, 'Invalid negative rate');
        RAISE EXCEPTION 'Expected negative insurance daily rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.additional_services (name, daily_rate)
        VALUES ('Invalid service', -1.00);
        RAISE EXCEPTION 'Expected negative additional service daily rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    SELECT id INTO service_id
    FROM catalog.additional_services
    WHERE name = 'Baby Seat';

    UPDATE catalog.additional_services
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = service_id;

    SELECT updated_at INTO service_updated_at
    FROM catalog.additional_services
    WHERE id = service_id;

    IF service_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected additional services updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-23 APPROVED: services, coverages, rate constraints, seeds and audit timestamp validated.';
END;
$$;

ROLLBACK;
