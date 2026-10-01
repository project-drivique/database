BEGIN;

DO $$
DECLARE
    bogota_city_id UUID;
    bogota_branch_id UUID;
    branch_updated_at TIMESTAMPTZ;
BEGIN
    SELECT id INTO bogota_city_id
    FROM location.cities
    WHERE name = 'Bogotá';

    IF bogota_city_id IS NULL THEN
        RAISE EXCEPTION 'Expected Bogotá city seed';
    END IF;

    SELECT id INTO bogota_branch_id
    FROM location.branches
    WHERE name = 'Drivique Bogotá Centro'
      AND city_id = bogota_city_id
      AND allows_cash_payment
      AND is_active;

    IF bogota_branch_id IS NULL THEN
        RAISE EXCEPTION 'Expected active Bogotá branch with cash payment enabled';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM location.branches
        WHERE name = 'Drivique Medellín Aeropuerto'
          AND NOT allows_cash_payment
    ) THEN
        RAISE EXCEPTION 'Expected airport branch with cash payment disabled';
    END IF;

    BEGIN
        INSERT INTO location.branches (
            name, address, city_id, phone, opening_time, closing_time
        ) VALUES (
            'Drivique Bogotá Centro', 'Test address', bogota_city_id,
            '+57 601 555 9999', '08:00', '18:00'
        );
        RAISE EXCEPTION 'Expected duplicated branch name to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO location.branches (
            name, address, city_id, phone, opening_time, closing_time
        ) VALUES (
            'Invalid hours branch', 'Test address', bogota_city_id,
            '+57 601 555 9999', '18:00', '08:00'
        );
        RAISE EXCEPTION 'Expected invalid business hours to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO location.branches (
            name, address, city_id, phone, opening_time, closing_time
        ) VALUES (
            'Unknown city branch', 'Test address',
            '00000000-0000-0000-0000-000000000000', '+57 601 555 9999',
            '08:00', '18:00'
        );
        RAISE EXCEPTION 'Expected branch with unknown city to fail';
    EXCEPTION
        WHEN foreign_key_violation THEN NULL;
    END;

    UPDATE location.branches
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = bogota_branch_id;

    SELECT updated_at INTO branch_updated_at
    FROM location.branches
    WHERE id = bogota_branch_id;

    IF branch_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected branches updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-15 APPROVED: branches, cash-payment points, constraints and audit timestamp validated.';
END;
$$;

ROLLBACK;
