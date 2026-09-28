CREATE UNIQUE INDEX uq_password_policies_one_active
    ON iam.password_policies (is_active)
    WHERE is_active;
