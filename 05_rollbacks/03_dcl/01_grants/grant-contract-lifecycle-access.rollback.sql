REVOKE SELECT, INSERT, UPDATE ON TABLE
    contract.rental_contracts,
    contract.contract_clause_assignments,
    contract.vehicle_inspections,
    contract.inspection_checklist_answers
FROM drivique_app;

REVOKE SELECT ON TABLE
    contract.contract_statuses,
    contract.contract_clauses,
    contract.inspection_checklist_items
FROM drivique_app;

REVOKE USAGE ON SCHEMA contract FROM drivique_app;
