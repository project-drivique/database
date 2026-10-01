CREATE TRIGGER trg_document_statuses_set_updated_at
BEFORE UPDATE ON iam.document_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
