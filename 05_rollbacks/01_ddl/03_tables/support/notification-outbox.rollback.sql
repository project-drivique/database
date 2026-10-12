DROP TRIGGER IF EXISTS trg_notification_outbox_set_updated_at ON support.notification_outbox;
DROP INDEX IF EXISTS support.idx_notification_outbox_channel;
DROP INDEX IF EXISTS support.idx_notification_outbox_notification;
DROP INDEX IF EXISTS support.idx_notification_outbox_pending;
DROP TABLE IF EXISTS support.notification_outbox;
