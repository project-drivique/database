CREATE TABLE contract.contract_clause_assignments (
    contract_id UUID NOT NULL,
    clause_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_contract_clause_assignments
        PRIMARY KEY (contract_id, clause_id),
    CONSTRAINT fk_contract_clause_assignments_contract
        FOREIGN KEY (contract_id) REFERENCES contract.rental_contracts (id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_clause_assignments_clause
        FOREIGN KEY (clause_id) REFERENCES contract.contract_clauses (id) ON DELETE RESTRICT
);
