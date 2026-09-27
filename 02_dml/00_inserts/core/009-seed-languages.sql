--liquibase formatted sql

--changeset danna:009-seed-languages labels:hu-bd-02
INSERT INTO core.languages (code, name, is_default, is_active)
VALUES
    ('es', 'Spanish', TRUE, TRUE),
    ('en', 'English', FALSE, TRUE),
    ('fr', 'French', FALSE, TRUE),
    ('pt', 'Portuguese', FALSE, TRUE),
    ('br', 'Brazilian Portuguese', FALSE, TRUE);

--rollback DELETE FROM core.languages WHERE code IN ('es', 'en', 'fr', 'pt', 'br');
