CREATE TRIGGER trg_vehicle_inspections_set_updated_at
BEFORE UPDATE ON contract.vehicle_inspections
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
