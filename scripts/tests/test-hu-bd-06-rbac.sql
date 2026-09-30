BEGIN;

DO $$
DECLARE
    role_count INTEGER;
    permission_count INTEGER;
    super_admin_perm_count INTEGER;
    branch_admin_perm_count INTEGER;
    employee_perm_count INTEGER;
    initial_updated_at TIMESTAMPTZ;
    updated_timestamp TIMESTAMPTZ;
    temp_role_id UUID;
    temp_perm_id UUID;
BEGIN
    -- 1. Check roles count and standard roles
    SELECT count(*) INTO role_count FROM iam.roles WHERE is_active = TRUE;
    IF role_count < 4 THEN
        RAISE EXCEPTION 'Expected at least 4 active roles, found %', role_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM iam.roles WHERE code = 'SUPER_ADMIN' AND name = 'Super Administrator'
    ) THEN
        RAISE EXCEPTION 'Expected SUPER_ADMIN role seed';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM iam.roles WHERE code = 'CUSTOMER' AND name = 'Customer'
    ) THEN
        RAISE EXCEPTION 'Expected CUSTOMER role seed';
    END IF;

    -- 2. Check permissions count
    SELECT count(*) INTO permission_count FROM iam.permissions;
    IF permission_count <> 14 THEN
        RAISE EXCEPTION 'Expected 14 granular permissions, found %', permission_count;
    END IF;

    -- 3. Check role permissions assignments
    SELECT count(*) INTO super_admin_perm_count
    FROM iam.role_permissions rp
    JOIN iam.roles r ON rp.role_id = r.id
    WHERE r.code = 'SUPER_ADMIN';

    IF super_admin_perm_count <> 14 THEN
        RAISE EXCEPTION 'Expected SUPER_ADMIN to have all 14 permissions, found %', super_admin_perm_count;
    END IF;

    SELECT count(*) INTO branch_admin_perm_count
    FROM iam.role_permissions rp
    JOIN iam.roles r ON rp.role_id = r.id
    WHERE r.code = 'BRANCH_ADMIN';

    IF branch_admin_perm_count <> 10 THEN
        RAISE EXCEPTION 'Expected BRANCH_ADMIN to have 10 permissions, found %', branch_admin_perm_count;
    END IF;

    SELECT count(*) INTO employee_perm_count
    FROM iam.role_permissions rp
    JOIN iam.roles r ON rp.role_id = r.id
    WHERE r.code = 'EMPLOYEE';

    IF employee_perm_count <> 5 THEN
        RAISE EXCEPTION 'Expected EMPLOYEE to have 5 permissions, found %', employee_perm_count;
    END IF;

    -- 4. Validation: Invalid code format should fail
    BEGIN
        INSERT INTO iam.roles (code, name) VALUES ('invalid_role_lowercase', 'Invalid Role');
        RAISE EXCEPTION 'Expected check constraint violation on invalid role code format';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    -- 5. Validation: Duplicate role code should fail
    BEGIN
        INSERT INTO iam.roles (code, name) VALUES ('SUPER_ADMIN', 'Duplicate Super Admin');
        RAISE EXCEPTION 'Expected unique constraint violation on duplicate role code';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    -- 6. Validation: Cascade delete on role deletes role_permissions
    INSERT INTO iam.roles (code, name) VALUES ('TEMP_TEST_ROLE', 'Temporary Test Role') RETURNING id INTO temp_role_id;
    SELECT id INTO temp_perm_id FROM iam.permissions LIMIT 1;
    INSERT INTO iam.role_permissions (role_id, permission_id) VALUES (temp_role_id, temp_perm_id);

    DELETE FROM iam.roles WHERE id = temp_role_id;
    IF EXISTS (SELECT 1 FROM iam.role_permissions WHERE role_id = temp_role_id) THEN
        RAISE EXCEPTION 'Expected cascade deletion of role_permissions when role is deleted';
    END IF;

    -- 7. Validation: updated_at trigger on roles
    SELECT updated_at INTO initial_updated_at FROM iam.roles WHERE code = 'CUSTOMER';
    UPDATE iam.roles SET updated_at = initial_updated_at - INTERVAL '1 day', description = 'Updated description' WHERE code = 'CUSTOMER';
    SELECT updated_at INTO updated_timestamp FROM iam.roles WHERE code = 'CUSTOMER';

    IF updated_timestamp <= initial_updated_at - INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Expected role updated_at trigger to refresh timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-06 APPROVED: RBAC roles, permissions, matrix and integrity constraints validated.';
END;
$$;

ROLLBACK;
