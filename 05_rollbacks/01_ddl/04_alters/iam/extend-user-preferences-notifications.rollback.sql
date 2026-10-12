ALTER TABLE iam.user_preferences
    DROP COLUMN IF EXISTS push_notifications,
    DROP COLUMN IF EXISTS in_app_notifications,
    DROP COLUMN IF EXISTS marketing_notifications;
