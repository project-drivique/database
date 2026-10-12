DROP INDEX IF EXISTS iam.idx_user_documents_branch_status;
ALTER TABLE iam.user_documents DROP CONSTRAINT IF EXISTS fk_user_documents_branch;
ALTER TABLE iam.user_documents DROP COLUMN IF EXISTS branch_id;
