CREATE TRIGGER trg_brand_configurations_set_updated_at
BEFORE UPDATE ON core.brand_configurations
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
