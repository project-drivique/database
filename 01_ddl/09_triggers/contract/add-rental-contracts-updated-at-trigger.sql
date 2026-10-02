CREATE TRIGGER trg_rental_contracts_set_updated_at
BEFORE UPDATE ON contract.rental_contracts
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();
