DROP TRIGGER IF EXISTS trg_notification_templates_set_updated_at ON support.notification_templates;
DROP INDEX IF EXISTS support.idx_notification_templates_event_channel;
DROP TABLE IF EXISTS support.notification_templates;
