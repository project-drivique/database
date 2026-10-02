CREATE TRIGGER trg_additional_services_set_updated_at
BEFORE UPDATE ON catalog.additional_services
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
