GRANT USAGE ON SCHEMA support TO drivique_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    support.notifications,
    support.notification_outbox
TO drivique_app;

GRANT SELECT, INSERT, UPDATE ON TABLE
    support.notification_delivery_attempts
TO drivique_app;

GRANT SELECT ON TABLE
    support.notification_templates
TO drivique_app;

GRANT SELECT, INSERT, UPDATE ON TABLE
    iam.user_preferences
TO drivique_app;
