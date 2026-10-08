INSERT INTO iam.document_types (code, name, requires_front_and_back) VALUES
    ('CC', 'Citizenship Card', TRUE),
    ('CE', 'Foreign Resident ID', TRUE),
    ('PASSPORT', 'Passport', FALSE),
    ('TI', 'Identity Card', TRUE),
    ('NIT', 'Tax Identification Number', FALSE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO iam.nationalities (name, iso_code) VALUES
    ('Argentina', 'AR'),
    ('Australia', 'AU'),
    ('Brazil', 'BR'),
    ('Canada', 'CA'),
    ('Chile', 'CL'),
    ('China', 'CN'),
    ('Colombia', 'CO'),
    ('Ecuador', 'EC'),
    ('France', 'FR'),
    ('Germany', 'DE'),
    ('India', 'IN'),
    ('Italy', 'IT'),
    ('Japan', 'JP'),
    ('Mexico', 'MX'),
    ('Peru', 'PE'),
    ('Spain', 'ES'),
    ('United Kingdom', 'GB'),
    ('United States', 'US'),
    ('Venezuela', 'VE')
ON CONFLICT (iso_code) DO NOTHING;

INSERT INTO iam.document_statuses (code, name) VALUES
    ('PENDING', 'Pending'),
    ('APPROVED', 'Approved'),
    ('REJECTED', 'Rejected')
ON CONFLICT (code) DO NOTHING;
