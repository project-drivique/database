CREATE INDEX IF NOT EXISTS idx_user_preferences_lang ON iam.user_preferences (language_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_curr ON iam.user_preferences (currency_id);
