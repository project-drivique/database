UPDATE iam.document_types
SET is_mandatory = TRUE;

UPDATE iam.document_types
SET is_active = TRUE
WHERE code = 'TI';
