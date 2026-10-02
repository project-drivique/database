CREATE TRIGGER trg_contract_statuses_set_updated_at
BEFORE UPDATE ON contract.contract_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
