CREATE TRIGGER trg_payments_set_updated_at
BEFORE UPDATE ON billing.payments
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
