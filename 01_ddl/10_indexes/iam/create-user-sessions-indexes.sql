CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON iam.user_sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_exp ON iam.user_sessions (expires_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_revoked ON iam.user_sessions (revoked_at);
