BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    bogota_city_id UUID;
    temporary_branch_id UUID;
BEGIN
    SELECT id INTO admin_user_id
    FROM iam.users
    WHERE email = 'admin@drivique.com';

    IF admin_user_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    SELECT id INTO bogota_city_id
    FROM location.cities
    WHERE name = 'Bogotá';

    IF bogota_city_id IS NULL THEN
        RAISE EXCEPTION 'Expected Bogotá city seed';
    END IF;

    INSERT INTO location.branches (
        name, address, city_id, phone, opening_time, closing_time
    ) VALUES (
        'HU-BD-16 Temporary Branch', 'Test address', bogota_city_id,
        '+57 601 555 9999', '08:00', '18:00'
    ) RETURNING id INTO temporary_branch_id;

    INSERT INTO location.branch_users (user_id, branch_id)
    VALUES (admin_user_id, temporary_branch_id);

    BEGIN
        INSERT INTO location.branch_users (user_id, branch_id)
        VALUES (admin_user_id, temporary_branch_id);
        RAISE EXCEPTION 'Expected duplicate user-branch assignment to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO location.branch_users (user_id, branch_id)
        VALUES (admin_user_id, '00000000-0000-0000-0000-000000000000');
        RAISE EXCEPTION 'Expected assignment with unknown branch to fail';
    EXCEPTION
        WHEN foreign_key_violation THEN NULL;
    END;

    DELETE FROM location.branches
    WHERE id = temporary_branch_id;

    IF EXISTS (
        SELECT 1
        FROM location.branch_users
        WHERE user_id = admin_user_id
          AND branch_id = temporary_branch_id
    ) THEN
        RAISE EXCEPTION 'Expected branch assignment to be deleted with its branch';
    END IF;

    RAISE NOTICE 'HU-BD-16 APPROVED: composite key, foreign keys and branch cascade validated.';
END;
$$;

ROLLBACK;
