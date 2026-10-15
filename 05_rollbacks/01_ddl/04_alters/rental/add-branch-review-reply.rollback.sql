REVOKE UPDATE, DELETE ON rental.branch_reviews FROM drivique_app;

ALTER TABLE rental.branch_reviews
    DROP CONSTRAINT IF EXISTS fk_branch_reviews_replied_by,
    DROP CONSTRAINT IF EXISTS chk_branch_reviews_reply_not_blank,
    DROP COLUMN IF EXISTS manager_reply,
    DROP COLUMN IF EXISTS replied_at,
    DROP COLUMN IF EXISTS replied_by;
