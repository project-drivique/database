CREATE OR REPLACE TRIGGER trg_user_sessions_updated_at
BEFORE UPDATE ON iam.user_sessions
FOR EACH ROW
EXECUTE FUNCTION public.fn_set_updated_at();
