DELETE FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order BETWEEN 1 AND 5 AND NOT EXISTS (SELECT 1 FROM contract.rental_contracts LIMIT 1);
