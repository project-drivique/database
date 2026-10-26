-- ============================================================================
-- SEED: Super Administrator User
-- NOTA DE SEGURIDAD:
-- En ambientes de producción o staging, defina la configuración de sesión:
--   SET app.admin_password_hash = '<hash_bcrypt_seguro>';
-- Si no está definida, la cuenta queda BLOQUEADA (sin contraseña conocida) y la API le asigna
-- la contraseña real al arrancar a partir de BOOTSTRAP_ADMIN_PASSWORD.
-- ============================================================================

INSERT INTO iam.users (
    id, first_name, last_name, email, document_number, password_hash, account_status, is_profile_complete, email_verified_at
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Super',
    'Administrator',
    'admin@drivique.com',
    '1000000000',
    COALESCE(NULLIF(current_setting('app.admin_password_hash', true), ''), '!LOCKED-DEFINE-BOOTSTRAP-PASSWORD'),
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
