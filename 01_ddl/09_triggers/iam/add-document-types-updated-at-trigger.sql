CREATE TRIGGER trg_document_types_set_updated_at
BEFORE UPDATE ON iam.document_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
