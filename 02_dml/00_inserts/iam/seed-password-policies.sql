INSERT INTO iam.password_policies (
    policy_name, min_length, require_uppercase, require_number, require_symbol,
    password_history_limit, expiration_days, is_active
) VALUES (
    'DRIVIQUE_DEFAULT', 12, TRUE, TRUE, TRUE, 5, 90, TRUE
);
