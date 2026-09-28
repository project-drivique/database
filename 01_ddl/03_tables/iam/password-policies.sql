CREATE TABLE iam.password_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_name VARCHAR(80) NOT NULL,
    min_length SMALLINT NOT NULL,
    require_uppercase BOOLEAN NOT NULL DEFAULT TRUE,
    require_number BOOLEAN NOT NULL DEFAULT TRUE,
    require_symbol BOOLEAN NOT NULL DEFAULT TRUE,
    password_history_limit SMALLINT NOT NULL DEFAULT 5,
    expiration_days SMALLINT NOT NULL DEFAULT 90,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_password_policies_name UNIQUE (policy_name),
    CONSTRAINT chk_password_policies_min_length CHECK (min_length >= 8),
    CONSTRAINT chk_password_policies_history_limit CHECK (password_history_limit >= 0),
    CONSTRAINT chk_password_policies_expiration_days CHECK (expiration_days > 0)
);
