ALTER TABLE iam.user_documents
    DROP COLUMN document_number;

ALTER TABLE iam.document_types
    DROP COLUMN is_mandatory,
    DROP COLUMN description;
