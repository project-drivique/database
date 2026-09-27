--liquibase formatted sql

--changeset danna:008-create-default-catalog-indexes labels:hu-bd-02
CREATE UNIQUE INDEX uq_languages_one_default
    ON core.languages (is_default)
    WHERE is_default;

CREATE UNIQUE INDEX uq_currencies_one_default
    ON core.currencies (is_default)
    WHERE is_default;

--rollback DROP INDEX core.uq_languages_one_default;
--rollback DROP INDEX core.uq_currencies_one_default;
