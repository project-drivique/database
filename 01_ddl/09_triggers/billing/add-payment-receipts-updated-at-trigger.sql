CREATE TRIGGER trg_payment_receipts_set_updated_at
BEFORE UPDATE ON billing.payment_receipts
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
