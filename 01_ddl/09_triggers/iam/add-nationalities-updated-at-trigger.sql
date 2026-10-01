CREATE TRIGGER trg_nationalities_set_updated_at
BEFORE UPDATE ON iam.nationalities
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
