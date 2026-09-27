--liquibase formatted sql

--changeset danna:007-add-currencies-updated-at-trigger labels:hu-bd-02
CREATE TRIGGER trg_currencies_set_updated_at
BEFORE UPDATE ON core.currencies
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

--rollback DROP TRIGGER trg_currencies_set_updated_at ON core.currencies;
