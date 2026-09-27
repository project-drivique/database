--liquibase formatted sql

--changeset danna:004-create-currencies-table labels:hu-bd-02
CREATE TABLE core.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_currencies_code UNIQUE (code),
    CONSTRAINT uq_currencies_name UNIQUE (name),
    CONSTRAINT chk_currencies_code_format CHECK (code ~ '^[A-Z]{3}$')
);

--rollback DROP TABLE core.currencies;
