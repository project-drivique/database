BEGIN;

DO $$
DECLARE
    confirmed_id UUID;
    status_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM rental.reservation_statuses) <> 7
       OR NOT EXISTS (SELECT 1 FROM rental.reservation_statuses WHERE code = 'PENDING_PAYMENT' AND blocks_availability)
       OR NOT EXISTS (SELECT 1 FROM rental.reservation_statuses WHERE code = 'CONFIRMED' AND blocks_availability)
       OR EXISTS (SELECT 1 FROM rental.reservation_statuses WHERE code IN ('COMPLETED', 'CANCELLED_BY_TIMEOUT', 'CANCELLED_BY_USER', 'REJECTED') AND blocks_availability) THEN
        RAISE EXCEPTION 'Expected reservation lifecycle seeds and availability behavior';
    END IF;

    BEGIN
        INSERT INTO rental.reservation_statuses (code, name)
        VALUES ('CONFIRMED', 'Duplicate');
        RAISE EXCEPTION 'Expected duplicate status code to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO rental.reservation_statuses (code, name)
        VALUES ('invalid', 'Invalid');
        RAISE EXCEPTION 'Expected lowercase status code to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    SELECT id INTO confirmed_id FROM rental.reservation_statuses WHERE code = 'CONFIRMED';
    UPDATE rental.reservation_statuses SET updated_at = '2000-01-01 00:00:00+00' WHERE id = confirmed_id;
    SELECT updated_at INTO status_updated_at FROM rental.reservation_statuses WHERE id = confirmed_id;

    IF status_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected reservation status audit trigger';
    END IF;

    RAISE NOTICE 'HU-BD-26 APPROVED: reservation states, uniqueness and availability blocking validated.';
END;
$$;

ROLLBACK;
