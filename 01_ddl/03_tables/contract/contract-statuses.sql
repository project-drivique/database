CREATE TABLE contract.contract_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL,
    name VARCHAR(80) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_contract_statuses_code UNIQUE (code),
    CONSTRAINT uq_contract_statuses_name UNIQUE (name),
    CONSTRAINT chk_contract_statuses_code_not_blank CHECK (btrim(code) <> ''),
    CONSTRAINT chk_contract_statuses_name_not_blank CHECK (btrim(name) <> '')
);
