CREATE TRIGGER trg_payment_methods_set_updated_at
BEFORE UPDATE ON billing.payment_methods
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
