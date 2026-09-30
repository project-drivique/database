CREATE TRIGGER trg_roles_set_updated_at
BEFORE UPDATE ON iam.roles
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
