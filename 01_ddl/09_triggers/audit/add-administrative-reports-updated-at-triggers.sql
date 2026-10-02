CREATE TRIGGER trg_administrative_report_types_set_updated_at
BEFORE UPDATE ON audit.administrative_report_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_generated_reports_set_updated_at
BEFORE UPDATE ON audit.generated_reports
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
