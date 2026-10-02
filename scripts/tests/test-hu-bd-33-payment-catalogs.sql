BEGIN;

DO $$
DECLARE
    method_id UUID;
    method_updated_at TIMESTAMPTZ;
BEGIN
    IF (SELECT COUNT(*) FROM billing.payment_methods) <> 6
       OR NOT EXISTS (SELECT 1 FROM billing.payment_methods WHERE code = 'CASH')
       OR NOT EXISTS (SELECT 1 FROM billing.payment_methods WHERE code = 'BANCOLOMBIA') THEN
        RAISE EXCEPTION 'Expected all payment method seeds';
    END IF;

    IF (SELECT COUNT(*) FROM billing.payment_statuses) <> 5
       OR NOT EXISTS (SELECT 1 FROM billing.payment_statuses WHERE code = 'PENDING' AND NOT is_final)
       OR EXISTS (SELECT 1 FROM billing.payment_statuses WHERE code IN ('APPROVED', 'DECLINED', 'REFUNDED', 'VOIDED') AND NOT is_final) THEN
        RAISE EXCEPTION 'Expected payment status seeds and final-state behavior';
    END IF;

    BEGIN
        INSERT INTO billing.payment_methods (code, name) VALUES ('CASH', 'Duplicate');
        RAISE EXCEPTION 'Expected duplicate payment method code to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO billing.payment_statuses (code, name) VALUES ('approved', 'Invalid');
        RAISE EXCEPTION 'Expected lowercase payment status code to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    SELECT id INTO method_id FROM billing.payment_methods WHERE code = 'CASH';
    UPDATE billing.payment_methods SET updated_at = '2000-01-01 00:00:00+00' WHERE id = method_id;
    SELECT updated_at INTO method_updated_at FROM billing.payment_methods WHERE id = method_id;
    IF method_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected payment method audit trigger';
    END IF;

    RAISE NOTICE 'HU-BD-33 APPROVED: payment methods, statuses, seeds and uniqueness validated.';
END;
$$;

ROLLBACK;
