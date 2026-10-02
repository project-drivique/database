CREATE TRIGGER trg_insurance_coverages_set_updated_at
BEFORE UPDATE ON catalog.insurance_coverages
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
