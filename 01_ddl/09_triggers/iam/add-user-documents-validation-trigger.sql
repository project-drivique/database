CREATE TRIGGER trg_user_documents_validate
BEFORE INSERT OR UPDATE ON iam.user_documents
FOR EACH ROW
EXECUTE FUNCTION iam.validate_user_document();
