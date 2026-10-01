CREATE TRIGGER trg_user_documents_set_updated_at
BEFORE UPDATE ON iam.user_documents
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
