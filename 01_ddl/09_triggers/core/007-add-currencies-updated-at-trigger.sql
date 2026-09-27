CREATE TRIGGER trg_currencies_set_updated_at
BEFORE UPDATE ON core.currencies
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
