CREATE TRIGGER trg_departments_set_updated_at
BEFORE UPDATE ON location.departments
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
