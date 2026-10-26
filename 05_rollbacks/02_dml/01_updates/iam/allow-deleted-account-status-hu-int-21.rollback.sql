ALTER TABLE iam.users DROP CONSTRAINT IF EXISTS chk_users_account_status;
ALTER TABLE iam.users ADD CONSTRAINT chk_users_account_status
    CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'LOCKED', 'PENDING_VERIFICATION'));
