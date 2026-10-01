ALTER TABLE iam.users
    DROP CONSTRAINT IF EXISTS fk_users_document_type,
    DROP CONSTRAINT IF EXISTS fk_users_nationality;
