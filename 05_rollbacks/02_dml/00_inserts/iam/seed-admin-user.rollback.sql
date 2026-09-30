DELETE FROM iam.user_roles WHERE user_id IN (SELECT id FROM iam.users WHERE email = 'admin@drivique.com');
DELETE FROM iam.users WHERE email = 'admin@drivique.com';
