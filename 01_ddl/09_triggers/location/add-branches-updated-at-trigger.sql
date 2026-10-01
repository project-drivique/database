CREATE TRIGGER trg_branches_set_updated_at
BEFORE UPDATE ON location.branches
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
