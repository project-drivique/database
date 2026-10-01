CREATE TRIGGER trg_vehicle_statuses_set_updated_at
BEFORE UPDATE ON fleet.vehicle_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
