INSERT INTO iam.security_configurations (config_key, config_value, description) VALUES
    ('MAX_LOGIN_ATTEMPTS', '5', 'Maximum consecutive failed login attempts before account lockout.'),
    ('ACCOUNT_LOCKOUT_MINUTES', '30', 'Duration of an account lockout after reaching the maximum failed attempts.'),
    ('MFA_REQUIRED_FOR_ADMINS', 'true', 'Whether multi-factor authentication is required for administrator accounts.'),
    ('SESSION_IDLE_TIMEOUT_MINUTES', '30', 'Maximum inactive session duration before the user must authenticate again.'),
    ('PASSWORD_RESET_TOKEN_EXPIRATION_MINUTES', '15', 'Validity duration for password reset tokens.');
