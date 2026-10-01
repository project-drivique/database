CREATE TABLE iam.user_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    consent_type VARCHAR(60) NOT NULL,
    document_version VARCHAR(40) NOT NULL,
    accepted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address INET NOT NULL,
    CONSTRAINT fk_user_consents_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id),
    CONSTRAINT uq_user_consents_user_type_version
        UNIQUE (user_id, consent_type, document_version),
    CONSTRAINT chk_user_consents_type_not_blank
        CHECK (btrim(consent_type) <> ''),
    CONSTRAINT chk_user_consents_version_not_blank
        CHECK (btrim(document_version) <> '')
);
