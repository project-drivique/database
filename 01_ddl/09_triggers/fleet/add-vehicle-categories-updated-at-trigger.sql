CREATE TRIGGER trg_vehicle_categories_set_updated_at
BEFORE UPDATE ON fleet.vehicle_categories
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
