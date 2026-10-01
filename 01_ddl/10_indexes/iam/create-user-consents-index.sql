CREATE INDEX idx_user_consents_user_accepted_at
    ON iam.user_consents (user_id, accepted_at DESC);
