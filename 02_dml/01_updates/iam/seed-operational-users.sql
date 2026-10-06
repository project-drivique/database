UPDATE iam.users
SET password_hash = '$2a$12$iIrC/bchcMQVAN7jkJSuTOGvGKtorg5NKnP3qRcXpsdEHM5jP02BS',
    account_status = 'ACTIVE',
    email_verified_at = COALESCE(email_verified_at, CURRENT_TIMESTAMP),
    failed_login_attempts = 0,
    locked_until = NULL,
    deleted_at = NULL,
    updated_at = CURRENT_TIMESTAMP
WHERE lower(email) = 'admin@drivique.com';

INSERT INTO iam.users (
    id, first_name, last_name, email, document_number, password_hash,
    account_status, is_profile_complete, email_verified_at
)
VALUES
    ('b0000000-0000-0000-0000-000000000001', 'Encargado', 'Bogotá Centro', 'encargado.bogota@drivique.com', '2000000001', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP),
    ('b0000000-0000-0000-0000-000000000002', 'Encargado', 'Medellín Centro', 'encargado.medellin.centro@drivique.com', '2000000002', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP),
    ('b0000000-0000-0000-0000-000000000003', 'Encargado', 'Medellín Aeropuerto', 'encargado.medellin.aeropuerto@drivique.com', '2000000003', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP),
    ('b0000000-0000-0000-0000-000000000004', 'Encargado', 'Cali Centro', 'encargado.cali@drivique.com', '2000000004', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP),
    ('b0000000-0000-0000-0000-000000000005', 'Encargado', 'Barranquilla Centro', 'encargado.barranquilla@drivique.com', '2000000005', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP),
    ('b0000000-0000-0000-0000-000000000006', 'Encargado', 'Cartagena Centro', 'encargado.cartagena@drivique.com', '2000000006', '$2a$12$ohhMKXdkbVYLg6y9/X.7gOXIkbXqnxNl2LO6KOM2m/2vKnttSGfzS', 'ACTIVE', TRUE, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO UPDATE
SET password_hash = EXCLUDED.password_hash,
    account_status = 'ACTIVE',
    is_profile_complete = TRUE,
    email_verified_at = COALESCE(iam.users.email_verified_at, CURRENT_TIMESTAMP),
    failed_login_attempts = 0,
    locked_until = NULL,
    deleted_at = NULL,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO iam.user_roles (user_id, role_id)
SELECT users.id, roles.id
FROM iam.users users
CROSS JOIN iam.roles roles
WHERE users.email IN (
    'encargado.bogota@drivique.com',
    'encargado.medellin.centro@drivique.com',
    'encargado.medellin.aeropuerto@drivique.com',
    'encargado.cali@drivique.com',
    'encargado.barranquilla@drivique.com',
    'encargado.cartagena@drivique.com'
)
AND roles.code = 'BRANCH_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO location.branch_users (user_id, branch_id)
SELECT users.id, branches.id
FROM (
    VALUES
        ('encargado.bogota@drivique.com', 'Drivique Bogotá Centro'),
        ('encargado.medellin.centro@drivique.com', 'Drivique Medellín Centro'),
        ('encargado.medellin.aeropuerto@drivique.com', 'Drivique Medellín Aeropuerto'),
        ('encargado.cali@drivique.com', 'Drivique Cali Centro'),
        ('encargado.barranquilla@drivique.com', 'Drivique Barranquilla Centro'),
        ('encargado.cartagena@drivique.com', 'Drivique Cartagena Centro')
) AS assignments(email, branch_name)
JOIN iam.users users ON users.email = assignments.email
JOIN location.branches branches ON branches.name = assignments.branch_name
ON CONFLICT DO NOTHING;
