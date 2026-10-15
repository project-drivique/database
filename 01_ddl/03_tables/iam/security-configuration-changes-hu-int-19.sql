CREATE TABLE IF NOT EXISTS iam.security_configuration_changes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key varchar(100) NOT NULL,
    old_value text,
    new_value text NOT NULL,
    reason varchar(300),
    reverted boolean NOT NULL DEFAULT false,
    changed_by uuid NOT NULL REFERENCES iam.users (id),
    changed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_security_configuration_changes_key ON iam.security_configuration_changes (config_key, changed_at DESC);
