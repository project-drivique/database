CREATE TRIGGER trg_vehicle_documents_updated_at
BEFORE UPDATE ON fleet.vehicle_documents
FOR EACH ROW
EXECUTE FUNCTION core.touch_updated_at();
