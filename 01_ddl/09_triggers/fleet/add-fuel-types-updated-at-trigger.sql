CREATE TRIGGER trg_fuel_types_set_updated_at
BEFORE UPDATE ON fleet.fuel_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
