--liquibase formatted sql

--changeset danna:010-seed-currencies labels:hu-bd-02
INSERT INTO core.currencies (code, name, symbol, is_default, is_active)
VALUES
    ('COP', 'Colombian Peso', '$', TRUE, TRUE),
    ('USD', 'United States Dollar', '$', FALSE, TRUE),
    ('EUR', 'Euro', '€', FALSE, TRUE);

--rollback DELETE FROM core.currencies WHERE code IN ('COP', 'USD', 'EUR');
