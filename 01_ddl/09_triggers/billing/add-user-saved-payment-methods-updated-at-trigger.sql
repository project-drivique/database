CREATE TRIGGER trg_user_saved_payment_methods_set_updated_at
BEFORE UPDATE ON billing.user_saved_payment_methods
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
