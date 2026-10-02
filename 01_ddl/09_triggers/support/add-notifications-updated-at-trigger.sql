CREATE TRIGGER trg_notifications_set_updated_at
BEFORE UPDATE ON support.notifications
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
