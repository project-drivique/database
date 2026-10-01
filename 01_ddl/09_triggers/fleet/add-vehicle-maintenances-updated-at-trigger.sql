CREATE TRIGGER trg_vehicle_maintenances_updated_at
BEFORE UPDATE ON fleet.vehicle_maintenances
FOR EACH ROW
EXECUTE FUNCTION core.touch_updated_at();
