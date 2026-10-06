DELETE FROM iam.users
WHERE email IN (
    'encargado.bogota@drivique.com',
    'encargado.medellin.centro@drivique.com',
    'encargado.medellin.aeropuerto@drivique.com',
    'encargado.cali@drivique.com',
    'encargado.barranquilla@drivique.com',
    'encargado.cartagena@drivique.com'
);

UPDATE iam.users
SET password_hash = '$2a$12$e8wF3QvY3bJ1mD1P2Q4c3eB7vH9aX0zW8yV7uT6sR5qP4oN3mL2kK',
    updated_at = CURRENT_TIMESTAMP
WHERE lower(email) = 'admin@drivique.com';
