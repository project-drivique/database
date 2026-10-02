BEGIN;

DO $$
DECLARE
    standard_plan_id UUID;
    plan_updated_at TIMESTAMPTZ;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM catalog.mileage_plans
        WHERE name = 'Standard 200 km'
          AND included_km = 200
          AND daily_rate = 0
          AND extra_km_rate = 850
    ) THEN
        RAISE EXCEPTION 'Expected standard mileage plan seed';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM catalog.mileage_plans
        WHERE name = 'Unlimited Mileage'
          AND included_km IS NULL
          AND extra_km_rate = 0
    ) THEN
        RAISE EXCEPTION 'Expected unlimited mileage plan seed';
    END IF;

    BEGIN
        INSERT INTO catalog.mileage_plans (
            name, included_km, daily_rate, extra_km_rate
        ) VALUES (
            'Standard 200 km', 100, 0.00, 500.00
        );
        RAISE EXCEPTION 'Expected duplicate mileage plan name to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.mileage_plans (
            name, included_km, daily_rate, extra_km_rate
        ) VALUES (
            'Invalid kilometers', -1, 0.00, 500.00
        );
        RAISE EXCEPTION 'Expected negative included kilometers to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.mileage_plans (
            name, included_km, daily_rate, extra_km_rate
        ) VALUES (
            'Invalid daily rate', 100, -1.00, 500.00
        );
        RAISE EXCEPTION 'Expected negative daily rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.mileage_plans (
            name, included_km, daily_rate, extra_km_rate
        ) VALUES (
            'Invalid extra rate', 100, 0.00, -1.00
        );
        RAISE EXCEPTION 'Expected negative extra kilometer rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    SELECT id INTO standard_plan_id
    FROM catalog.mileage_plans
    WHERE name = 'Standard 200 km';

    UPDATE catalog.mileage_plans
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = standard_plan_id;

    SELECT updated_at INTO plan_updated_at
    FROM catalog.mileage_plans
    WHERE id = standard_plan_id;

    IF plan_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected mileage plans updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-24 APPROVED: limited and unlimited plans, rates, constraints and audit timestamp validated.';
END;
$$;

ROLLBACK;
