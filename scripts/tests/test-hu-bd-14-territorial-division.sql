BEGIN;

DO $$
DECLARE
    bogota_department_id UUID;
    bogota_city_id UUID;
    test_department_id UUID;
    city_updated_at TIMESTAMPTZ;
BEGIN
    SELECT id INTO bogota_department_id
    FROM location.departments
    WHERE name = 'Bogotá D.C.';

    IF bogota_department_id IS NULL THEN
        RAISE EXCEPTION 'Expected Bogotá D.C. department seed';
    END IF;

    SELECT id INTO bogota_city_id
    FROM location.cities
    WHERE department_id = bogota_department_id
      AND name = 'Bogotá'
      AND has_airport
      AND has_terminal;

    IF bogota_city_id IS NULL THEN
        RAISE EXCEPTION 'Expected Bogotá city seed with airport and terminal';
    END IF;

    BEGIN
        INSERT INTO location.departments (name) VALUES ('Bogotá D.C.');
        RAISE EXCEPTION 'Expected duplicated department name to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO location.cities (department_id, name)
        VALUES (bogota_department_id, 'Bogotá');
        RAISE EXCEPTION 'Expected duplicated city in the same department to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    INSERT INTO location.departments (name)
    VALUES ('Temporary Test Department')
    RETURNING id INTO test_department_id;

    INSERT INTO location.cities (department_id, name)
    VALUES (test_department_id, 'Bogotá');

    BEGIN
        INSERT INTO location.cities (department_id, name)
        VALUES ('00000000-0000-0000-0000-000000000000', 'Invalid city');
        RAISE EXCEPTION 'Expected city with unknown department to fail';
    EXCEPTION
        WHEN foreign_key_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO location.cities (department_id, name)
        VALUES (bogota_department_id, ' ');
        RAISE EXCEPTION 'Expected blank city name to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    UPDATE location.cities
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = bogota_city_id;

    SELECT updated_at INTO city_updated_at
    FROM location.cities
    WHERE id = bogota_city_id;

    IF city_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected cities updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-14 APPROVED: territorial relations, seeds, constraints and audit timestamps validated.';
END;
$$;

ROLLBACK;
