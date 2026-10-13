INSERT INTO iam.document_types (code, name, requires_front_and_back, is_active) VALUES
    ('CC', 'Citizenship Card', TRUE, TRUE),
    ('CE', 'Foreign Resident ID', TRUE, TRUE),
    ('PASSPORT', 'Passport', FALSE, TRUE),
    ('TI', 'Identity Card', TRUE, FALSE),
    ('NIT', 'Tax Identification Number', FALSE, TRUE),
    ('DRIVER_LICENSE', 'Driver License', FALSE, TRUE)
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
