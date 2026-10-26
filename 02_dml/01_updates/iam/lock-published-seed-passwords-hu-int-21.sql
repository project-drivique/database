-- Cuentas operativas que todavia tengan una contrasena que estuvo publicada en el repositorio:
-- se bloquean. La API les asigna la contrasena real al arrancar (BOOTSTRAP_ADMIN_PASSWORD / BOOTSTRAP_BRANCH_ADMIN_PASSWORD).
UPDATE iam.users
SET password_hash = '!LOCKED-DEFINE-BOOTSTRAP-PASSWORD',
    updated_at = CURRENT_TIMESTAMP
WHERE lower(email) IN (
    'admin@drivique.com',
    'encargado.bogota@drivique.com',
    'encargado.medellin.centro@drivique.com',
    'encargado.medellin.aeropuerto@drivique.com',
    'encargado.cali@drivique.com',
    'encargado.barranquilla@drivique.com',
    'encargado.cartagena@drivique.com'
)
AND password_hash IN (
    '$2a$12$iIrC/bchcMQVAN7jkJSuTOGvGKtorg5NKnP3qRcXpsdEHM5jP02BS',
    '$2a$12$e8wF3QvY3bJ1mD1P2Q4c3eB7vH9aX0zW8yV7uT6sR5qP4oN3mL2kK'
);
