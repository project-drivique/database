CREATE TRIGGER trg_payment_statuses_set_updated_at
BEFORE UPDATE ON billing.payment_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
