INSERT INTO iam.permissions (code, name, description) VALUES
    ('USERS_READ', 'Read Users', 'View user accounts and profiles'),
    ('USERS_MANAGE', 'Manage Users', 'Create, update, lock, and manage user accounts'),
    ('ROLES_MANAGE', 'Manage Roles', 'Manage roles and permission assignments'),
    ('BRAND_CONFIGURATION_MANAGE', 'Manage Brand Configuration', 'Manage platform brand settings'),
    ('BRANCHES_MANAGE', 'Manage Branches', 'Manage cities, branches, and branch staff'),
    ('FLEET_MANAGE', 'Manage Fleet', 'Manage vehicles, maintenance, and fleet catalogs'),
    ('CATALOG_MANAGE', 'Manage Catalog', 'Manage prices, coverages, services, and promotions'),
    ('RESERVATIONS_READ', 'Read Reservations', 'View reservations and availability'),
    ('RESERVATIONS_MANAGE', 'Manage Reservations', 'Create and manage reservation lifecycle'),
    ('CONTRACTS_MANAGE', 'Manage Contracts', 'Create contracts, inspections, and signatures'),
    ('PAYMENTS_MANAGE', 'Manage Payments', 'Process payments and cash confirmations'),
    ('SUPPORT_MANAGE', 'Manage Support', 'Manage tickets, incidents, and notifications'),
    ('REPORTS_READ', 'Read Reports', 'Generate and view operational reports'),
    ('AUDIT_READ', 'Read Audit Log', 'View auditable business events')
ON CONFLICT (code) DO NOTHING;
