GRANT USAGE ON SCHEMA contract TO drivique_app;

GRANT SELECT ON TABLE
    contract.contract_statuses,
    contract.contract_clauses,
    contract.inspection_checklist_items
TO drivique_app;

GRANT SELECT, INSERT, UPDATE ON TABLE
    contract.rental_contracts,
    contract.contract_clause_assignments,
    contract.vehicle_inspections,
    contract.inspection_checklist_answers
TO drivique_app;
