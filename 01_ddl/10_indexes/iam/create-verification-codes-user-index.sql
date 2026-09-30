CREATE INDEX IF NOT EXISTS idx_verification_codes_user ON iam.verification_codes (user_id);
CREATE INDEX IF NOT EXISTS idx_verification_codes_exp ON iam.verification_codes (expires_at);
