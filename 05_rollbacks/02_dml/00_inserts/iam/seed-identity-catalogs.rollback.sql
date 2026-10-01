DELETE FROM iam.document_statuses WHERE code IN ('PENDING', 'APPROVED', 'REJECTED');
DELETE FROM iam.nationalities WHERE iso_code IN (
    'AR', 'AU', 'BR', 'CA', 'CL', 'CN', 'CO', 'EC', 'FR', 'DE',
    'IN', 'IT', 'JP', 'MX', 'PE', 'ES', 'GB', 'US', 'VE'
);
DELETE FROM iam.document_types WHERE code IN ('CC', 'CE', 'PASSPORT', 'TI', 'NIT');
