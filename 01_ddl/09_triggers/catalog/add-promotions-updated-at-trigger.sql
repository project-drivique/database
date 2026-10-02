CREATE TRIGGER trg_promotions_set_updated_at
BEFORE UPDATE ON catalog.promotions
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
