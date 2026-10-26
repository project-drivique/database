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
SET password_hash = '!LOCKED-DEFINE-BOOTSTRAP-PASSWORD',
    updated_at = CURRENT_TIMESTAMP
WHERE lower(email) = 'admin@drivique.com';
