ALTER TABLE iam.users
    ADD CONSTRAINT fk_users_document_type
        FOREIGN KEY (document_type_id) REFERENCES iam.document_types (id),
    ADD CONSTRAINT fk_users_nationality
        FOREIGN KEY (nationality_id) REFERENCES iam.nationalities (id);
