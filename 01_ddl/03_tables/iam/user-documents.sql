CREATE TABLE iam.user_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    document_type_id UUID NOT NULL,
    status_id UUID NOT NULL,
    front_url VARCHAR(1000) NOT NULL,
    back_url VARCHAR(1000),
    review_notes VARCHAR(500),
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_documents_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id),
    CONSTRAINT fk_user_documents_document_type
        FOREIGN KEY (document_type_id) REFERENCES iam.document_types (id),
    CONSTRAINT fk_user_documents_status
        FOREIGN KEY (status_id) REFERENCES iam.document_statuses (id),
    CONSTRAINT fk_user_documents_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES iam.users (id),
    CONSTRAINT chk_user_documents_front_url_not_blank
        CHECK (btrim(front_url) <> ''),
    CONSTRAINT chk_user_documents_back_url_not_blank
        CHECK (back_url IS NULL OR btrim(back_url) <> ''),
    CONSTRAINT chk_user_documents_review_notes_not_blank
        CHECK (review_notes IS NULL OR btrim(review_notes) <> '')
);
