INSERT INTO iam.users (
    id, first_name, last_name, email, document_number, password_hash, account_status, is_profile_complete, email_verified_at
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Super',
    'Administrator',
    'admin@drivique.com',
    '1000000000',
    '$2a$12$e8wF3QvY3bJ1mD1P2Q4c3eB7vH9aX0zW8yV7uT6sR5qP4oN3mL2kK',
    'ACTIVE',
    TRUE,
    CURRENT_TIMESTAMP
) ON CONFLICT (email) DO NOTHING;

INSERT INTO iam.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM iam.users u
CROSS JOIN iam.roles r
WHERE u.email = 'admin@drivique.com' AND r.code = 'SUPER_ADMIN'
ON CONFLICT DO NOTHING;
