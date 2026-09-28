CREATE TABLE iam.security_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT NOT NULL,
    description VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_security_configurations_key UNIQUE (config_key),
    CONSTRAINT chk_security_configurations_key_format CHECK (config_key ~ '^[A-Z][A-Z0-9_]*$'),
    CONSTRAINT chk_security_configurations_value_not_blank CHECK (btrim(config_value) <> ''),
    CONSTRAINT chk_security_configurations_description_not_blank CHECK (btrim(description) <> '')
);
