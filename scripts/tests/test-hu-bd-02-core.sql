BEGIN;

DO $$
DECLARE
    previous_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM core.languages) <> 5 THEN
        RAISE EXCEPTION 'Expected five seeded languages';
    END IF;

    IF (SELECT COUNT(*) FROM core.currencies) <> 3 THEN
        RAISE EXCEPTION 'Expected three seeded currencies';
    END IF;

    IF (SELECT code FROM core.currencies WHERE is_default) <> 'COP' THEN
        RAISE EXCEPTION 'COP must be the default currency';
    END IF;

    IF (SELECT COUNT(*) FROM core.languages WHERE is_default) <> 1 THEN
        RAISE EXCEPTION 'Expected exactly one default language';
    END IF;

    IF EXISTS (SELECT 1 FROM core.languages WHERE id IS NULL)
        OR EXISTS (SELECT 1 FROM core.currencies WHERE id IS NULL) THEN
        RAISE EXCEPTION 'UUID identifiers must be generated';
    END IF;

    BEGIN
        INSERT INTO core.languages (code, name) VALUES ('es', 'Duplicate Spanish');
        RAISE EXCEPTION 'Expected duplicate language code to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        UPDATE core.languages SET is_default = TRUE WHERE code = 'en';
        RAISE EXCEPTION 'Expected multiple default languages to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    SELECT updated_at INTO previous_updated_at FROM core.languages WHERE code = 'en';
    PERFORM pg_sleep(0.001);
    UPDATE core.languages SET name = 'English test value' WHERE code = 'en';

    IF (SELECT updated_at FROM core.languages WHERE code = 'en') <= previous_updated_at THEN
        RAISE EXCEPTION 'updated_at trigger did not update the timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-02 APPROVED: core catalogs, seeds, constraints and triggers validated.';
END;
$$;

ROLLBACK;
