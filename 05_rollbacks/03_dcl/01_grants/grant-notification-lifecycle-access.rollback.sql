REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE
    support.notifications,
    support.notification_outbox
FROM drivique_app;

REVOKE SELECT, INSERT, UPDATE ON TABLE
    support.notification_delivery_attempts
FROM drivique_app;

REVOKE SELECT ON TABLE
    support.notification_templates
FROM drivique_app;
