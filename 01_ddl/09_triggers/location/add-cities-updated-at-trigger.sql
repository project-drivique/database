CREATE TRIGGER trg_cities_set_updated_at
BEFORE UPDATE ON location.cities
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
