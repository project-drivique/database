CREATE TRIGGER trg_user_profiles_set_updated_at
BEFORE UPDATE ON iam.user_profiles
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
