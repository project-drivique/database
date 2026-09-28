BEGIN;

DO $$
DECLARE
    cop_id UUID;
    usd_id UUID;
    rate_timestamp TIMESTAMPTZ := '2026-09-27 00:00:00+00';
BEGIN
    SELECT id INTO cop_id FROM core.currencies WHERE code = 'COP';
    SELECT id INTO usd_id FROM core.currencies WHERE code = 'USD';

    INSERT INTO core.exchange_rates (
        from_currency_id, to_currency_id, rate, provider, fetched_at
    ) VALUES (
        cop_id, usd_id, 4000.500000, 'test-provider', rate_timestamp
    );

    BEGIN
        INSERT INTO core.exchange_rates (
            from_currency_id, to_currency_id, rate, provider, fetched_at
        ) VALUES (
            cop_id, usd_id, 0, 'test-provider', rate_timestamp + INTERVAL '1 minute'
        );
        RAISE EXCEPTION 'Expected a non-positive exchange rate to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO core.exchange_rates (
            from_currency_id, to_currency_id, rate, provider, fetched_at
        ) VALUES (
            cop_id, usd_id, 4000.500000, 'test-provider', rate_timestamp
        );
        RAISE EXCEPTION 'Expected a duplicated exchange rate snapshot to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO core.exchange_rates (
            from_currency_id, to_currency_id, rate, provider, fetched_at
        ) VALUES (
            cop_id, cop_id, 1, 'test-provider', rate_timestamp + INTERVAL '2 minutes'
        );
        RAISE EXCEPTION 'Expected an identical currency pair to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM core.exchange_rates
        WHERE from_currency_id = cop_id
          AND to_currency_id = usd_id
          AND provider = 'test-provider'
    ) THEN
        RAISE EXCEPTION 'Expected exchange rate was not persisted';
    END IF;

    RAISE NOTICE 'HU-BD-03 APPROVED: exchange rates, integrity and index contract validated.';
END;
$$;

ROLLBACK;
