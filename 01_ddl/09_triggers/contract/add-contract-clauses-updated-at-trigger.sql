CREATE TRIGGER trg_contract_clauses_set_updated_at
BEFORE UPDATE ON contract.contract_clauses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
