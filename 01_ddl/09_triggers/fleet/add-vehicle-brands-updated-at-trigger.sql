CREATE TRIGGER trg_vehicle_brands_set_updated_at
BEFORE UPDATE ON fleet.vehicle_brands
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
