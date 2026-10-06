-- ==============================================================================
-- Test Script: HU-INT-06 - Roles, permisos, sesión y navegación autorizada
-- ==============================================================================

BEGIN;

DO $$
DECLARE
    v_super_admin_id UUID;
    v_branch_admin_id UUID;
    v_employee_id UUID;
    v_customer_id UUID;
    v_branch_id UUID;
    v_perm_count INT;
BEGIN
    RAISE NOTICE 'Iniciando pruebas de HU-INT-06 (Roles, Permisos y Sucursales)...';

    -- 1. Validar existencia de roles estándar
    ASSERT EXISTS (SELECT 1 FROM iam.roles WHERE code = 'SUPER_ADMIN' AND is_active = TRUE), 'Error: Rol SUPER_ADMIN no existe o está inactivo.';
    ASSERT EXISTS (SELECT 1 FROM iam.roles WHERE code = 'BRANCH_ADMIN' AND is_active = TRUE), 'Error: Rol BRANCH_ADMIN no existe o está inactivo.';
    ASSERT EXISTS (SELECT 1 FROM iam.roles WHERE code = 'EMPLOYEE' AND is_active = TRUE), 'Error: Rol EMPLOYEE no existe o está inactivo.';
    ASSERT EXISTS (SELECT 1 FROM iam.roles WHERE code = 'CUSTOMER' AND is_active = TRUE), 'Error: Rol CUSTOMER no existe o está inactivo.';

    -- 2. Obtener una sucursal para pruebas
    SELECT id INTO v_branch_id FROM location.branches WHERE is_active = TRUE LIMIT 1;
    ASSERT v_branch_id IS NOT NULL, 'Error: No hay sucursales activas registradas.';

    -- 3. Crear usuarios de prueba para cada rol
    INSERT INTO iam.users (first_name, last_name, email, password_hash, account_status, is_profile_complete)
    VALUES ('Super', 'Admin', 'test.superadmin@drivique.com', '$2a$12$e8r0.hash', 'ACTIVE', TRUE)
    RETURNING id INTO v_super_admin_id;

    INSERT INTO iam.users (first_name, last_name, email, password_hash, account_status, is_profile_complete)
    VALUES ('Branch', 'Manager', 'test.branchadmin@drivique.com', '$2a$12$e8r0.hash', 'ACTIVE', TRUE)
    RETURNING id INTO v_branch_admin_id;

    INSERT INTO iam.users (first_name, last_name, email, password_hash, account_status, is_profile_complete)
    VALUES ('Branch', 'Staff', 'test.employee@drivique.com', '$2a$12$e8r0.hash', 'ACTIVE', TRUE)
    RETURNING id INTO v_employee_id;

    INSERT INTO iam.users (first_name, last_name, email, password_hash, account_status, is_profile_complete)
    VALUES ('App', 'Customer', 'test.customer@drivique.com', '$2a$12$e8r0.hash', 'ACTIVE', TRUE)
    RETURNING id INTO v_customer_id;

    -- 4. Asignar roles a los usuarios
    INSERT INTO iam.user_roles (user_id, role_id)
    SELECT v_super_admin_id, id FROM iam.roles WHERE code = 'SUPER_ADMIN';

    INSERT INTO iam.user_roles (user_id, role_id)
    SELECT v_branch_admin_id, id FROM iam.roles WHERE code = 'BRANCH_ADMIN';

    INSERT INTO iam.user_roles (user_id, role_id)
    SELECT v_employee_id, id FROM iam.roles WHERE code = 'EMPLOYEE';

    INSERT INTO iam.user_roles (user_id, role_id)
    SELECT v_customer_id, id FROM iam.roles WHERE code = 'CUSTOMER';

    -- 5. Asignar sucursales a personal operativo
    INSERT INTO location.branch_users (user_id, branch_id)
    VALUES (v_branch_admin_id, v_branch_id);

    INSERT INTO location.branch_users (user_id, branch_id)
    VALUES (v_employee_id, v_branch_id);

    -- 6. Validar consultas de permisos efectivos
    SELECT count(DISTINCT p.code) INTO v_perm_count
    FROM iam.user_roles ur
    JOIN iam.role_permissions rp ON rp.role_id = ur.role_id
    JOIN iam.permissions p ON p.id = rp.permission_id
    WHERE ur.user_id = v_super_admin_id;

    RAISE NOTICE 'Permisos de Super Admin encontrados: %', v_perm_count;

    -- 7. Validar asignación de sucursal
    ASSERT EXISTS (
        SELECT 1 FROM location.branch_users WHERE user_id = v_branch_admin_id AND branch_id = v_branch_id
    ), 'Error: No se asoció correctamente el usuario BRANCH_ADMIN a la sucursal.';

    RAISE NOTICE 'Pruebas de base de datos para HU-INT-06 completadas con éxito.';
END $$;

ROLLBACK;
