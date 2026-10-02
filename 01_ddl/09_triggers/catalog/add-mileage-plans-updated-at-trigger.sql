CREATE TRIGGER trg_mileage_plans_set_updated_at
BEFORE UPDATE ON catalog.mileage_plans
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
