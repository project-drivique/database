CREATE TRIGGER trg_password_policies_set_updated_at
BEFORE UPDATE ON iam.password_policies
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
