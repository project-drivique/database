CREATE TABLE fleet.features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    feature_group VARCHAR(30) NOT NULL,
    icon VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_features_name UNIQUE (name),
    CONSTRAINT chk_features_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_features_group CHECK (feature_group IN ('STANDARD', 'TECHNOLOGY', 'SECURITY', 'COMFORT'))
);
