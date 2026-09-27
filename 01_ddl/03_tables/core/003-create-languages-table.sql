CREATE TABLE core.languages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_languages_code UNIQUE (code),
    CONSTRAINT uq_languages_name UNIQUE (name),
    CONSTRAINT chk_languages_code_format CHECK (code ~ '^[a-z]{2}(-[A-Z]{2})?$')
);
