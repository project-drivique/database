ALTER TABLE iam.user_documents
    ADD COLUMN IF NOT EXISTS branch_id UUID;

ALTER TABLE iam.user_documents
    ADD CONSTRAINT fk_user_documents_branch
    FOREIGN KEY (branch_id) REFERENCES location.branches (id);

CREATE INDEX IF NOT EXISTS idx_user_documents_branch_status
    ON iam.user_documents (branch_id, status_id, created_at DESC);
