CREATE TABLE iam.document_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_document_statuses_code UNIQUE (code),
    CONSTRAINT uq_document_statuses_name UNIQUE (name),
    CONSTRAINT chk_document_statuses_code_format CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);
