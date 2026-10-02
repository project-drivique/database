CREATE TABLE contract.contract_clauses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version VARCHAR(40) NOT NULL,
    sort_order SMALLINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_contract_clauses_version_sort_order UNIQUE (version, sort_order),
    CONSTRAINT chk_contract_clauses_version_not_blank CHECK (btrim(version) <> ''),
    CONSTRAINT chk_contract_clauses_sort_order_positive CHECK (sort_order > 0),
    CONSTRAINT chk_contract_clauses_title_not_blank CHECK (btrim(title) <> ''),
    CONSTRAINT chk_contract_clauses_content_not_blank CHECK (btrim(content) <> '')
);
