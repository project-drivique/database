ALTER TABLE iam.document_types
    ADD COLUMN description VARCHAR(255),
    ADD COLUMN is_mandatory BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE iam.user_documents
    ADD COLUMN document_number VARCHAR(50);
