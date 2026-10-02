INSERT INTO contract.contract_statuses (code, name, is_active, is_final) VALUES
    ('DRAFT', 'Draft', FALSE, FALSE),
    ('PENDING_SIGNATURE', 'Pending Signature', TRUE, FALSE),
    ('ACTIVE', 'Active', TRUE, FALSE),
    ('FINALIZED', 'Finalized', FALSE, TRUE),
    ('CANCELLED', 'Cancelled', FALSE, TRUE)
ON CONFLICT (code) DO NOTHING;
