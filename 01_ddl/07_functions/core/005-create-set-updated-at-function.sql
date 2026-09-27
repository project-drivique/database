--liquibase formatted sql

--changeset danna:005-create-set-updated-at-function labels:hu-bd-02 splitStatements:false
CREATE FUNCTION core.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

--rollback DROP FUNCTION core.set_updated_at();
