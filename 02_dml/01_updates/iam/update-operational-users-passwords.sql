-- Sincronizar contraseñas de usuarios operativos para entornos locales con DriviqueAdmin2026!
UPDATE iam.users
SET password_hash = '$2a$12$iIrC/bchcMQVAN7jkJSuTOGvGKtorg5NKnP3qRcXpsdEHM5jP02BS',
    account_status = 'ACTIVE',
    updated_at = CURRENT_TIMESTAMP
WHERE email IN (
    'admin@drivique.com',
    'encargado.bogota@drivique.com',
    'encargado.medellin.centro@drivique.com',
    'encargado.medellin.aeropuerto@drivique.com',
    'encargado.cali@drivique.com',
    'encargado.barranquilla@drivique.com',
    'encargado.cartagena@drivique.com'
);
