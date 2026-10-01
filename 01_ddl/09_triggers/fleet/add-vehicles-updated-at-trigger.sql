CREATE TRIGGER trg_vehicles_set_updated_at
BEFORE UPDATE ON fleet.vehicles
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
