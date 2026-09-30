INSERT INTO iam.roles (code, name, description, is_active) VALUES
    ('SUPER_ADMIN', 'Super Administrator', 'Full system access and tenant management', TRUE),
    ('BRANCH_ADMIN', 'Branch Administrator', 'Branch-level operational management', TRUE),
    ('EMPLOYEE', 'Employee', 'Front-desk operations, inspections, and customer service', TRUE),
    ('CUSTOMER', 'Customer', 'End-user vehicle rental and profile self-service', TRUE)
ON CONFLICT (code) DO NOTHING;
