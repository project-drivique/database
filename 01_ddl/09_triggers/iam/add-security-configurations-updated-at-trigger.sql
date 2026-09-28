CREATE TRIGGER trg_security_configurations_set_updated_at
BEFORE UPDATE ON iam.security_configurations
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
