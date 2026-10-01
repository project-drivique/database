CREATE OR REPLACE TRIGGER trg_user_preferences_updated_at
BEFORE UPDATE ON iam.user_preferences
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
