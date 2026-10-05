REVOKE SELECT ON TABLE iam.roles, iam.permissions, iam.role_permissions FROM drivique_app;
REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE iam.users, iam.user_roles, iam.verification_codes FROM drivique_app;
REVOKE USAGE ON SCHEMA iam FROM drivique_app;
