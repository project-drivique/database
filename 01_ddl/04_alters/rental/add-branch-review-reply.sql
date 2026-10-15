ALTER TABLE rental.branch_reviews
    ADD COLUMN IF NOT EXISTS manager_reply VARCHAR(1000),
    ADD COLUMN IF NOT EXISTS replied_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS replied_by UUID;

ALTER TABLE rental.branch_reviews
    ADD CONSTRAINT fk_branch_reviews_replied_by FOREIGN KEY (replied_by) REFERENCES iam.users (id),
    ADD CONSTRAINT chk_branch_reviews_reply_not_blank CHECK (manager_reply IS NULL OR btrim(manager_reply) <> '');

GRANT UPDATE, DELETE ON rental.branch_reviews TO drivique_app;
