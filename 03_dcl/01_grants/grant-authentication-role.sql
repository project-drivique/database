GRANT USAGE ON SCHEMA iam TO drivique_app;

GRANT SELECT ON TABLE iam.roles, iam.permissions, iam.role_permissions TO drivique_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE iam.users, iam.user_roles, iam.verification_codes TO drivique_app;
