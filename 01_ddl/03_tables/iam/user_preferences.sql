CREATE TABLE IF NOT EXISTS iam.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES iam.users(id) ON DELETE CASCADE,
    language_id UUID REFERENCES config.languages(id) ON DELETE SET NULL,
    currency_id UUID REFERENCES config.currencies(id) ON DELETE SET NULL,
    theme_preference VARCHAR(20) NOT NULL DEFAULT 'SYSTEM' CHECK (theme_preference IN ('LIGHT', 'DARK', 'SYSTEM')),
    email_notifications BOOLEAN NOT NULL DEFAULT true,
    sms_notifications BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
