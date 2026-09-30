CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON iam.users
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
