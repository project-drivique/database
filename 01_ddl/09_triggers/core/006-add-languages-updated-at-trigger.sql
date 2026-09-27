--liquibase formatted sql

--changeset danna:006-add-languages-updated-at-trigger labels:hu-bd-02
CREATE TRIGGER trg_languages_set_updated_at
BEFORE UPDATE ON core.languages
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

--rollback DROP TRIGGER trg_languages_set_updated_at ON core.languages;
