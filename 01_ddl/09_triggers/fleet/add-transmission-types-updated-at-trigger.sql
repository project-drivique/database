CREATE TRIGGER trg_transmission_types_set_updated_at
BEFORE UPDATE ON fleet.transmission_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
