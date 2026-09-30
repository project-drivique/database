INSERT INTO iam.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM iam.roles AS role
CROSS JOIN iam.permissions AS permission
WHERE role.code = 'SUPER_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO iam.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM iam.roles AS role
JOIN iam.permissions AS permission ON permission.code IN (
    'USERS_READ', 'BRANCHES_MANAGE', 'FLEET_MANAGE', 'CATALOG_MANAGE',
    'RESERVATIONS_READ', 'RESERVATIONS_MANAGE', 'CONTRACTS_MANAGE',
    'PAYMENTS_MANAGE', 'SUPPORT_MANAGE', 'REPORTS_READ'
)
WHERE role.code = 'BRANCH_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO iam.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM iam.roles AS role
JOIN iam.permissions AS permission ON permission.code IN (
    'RESERVATIONS_READ', 'RESERVATIONS_MANAGE', 'CONTRACTS_MANAGE',
    'PAYMENTS_MANAGE', 'SUPPORT_MANAGE'
)
WHERE role.code = 'EMPLOYEE'
ON CONFLICT DO NOTHING;
