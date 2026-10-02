CREATE TRIGGER trg_incident_reports_set_updated_at
BEFORE UPDATE ON support.incident_reports
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_incident_responses_set_updated_at
BEFORE UPDATE ON support.incident_responses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
