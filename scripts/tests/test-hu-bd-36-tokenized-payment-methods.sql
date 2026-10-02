BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    saved_method_id UUID;
    saved_method_updated_at TIMESTAMPTZ;
    sensitive_column_count INTEGER;
BEGIN
    SELECT id INTO admin_user_id FROM iam.users WHERE email = 'admin@drivique.com';

    INSERT INTO billing.user_saved_payment_methods (
        user_id, payment_token, card_brand, last_four, exp_month, exp_year
    ) VALUES (
        admin_user_id, 'tok_test_drivique_001', 'VISA', '4242', 12, 2030
    ) RETURNING id INTO saved_method_id;

    BEGIN
        INSERT INTO billing.user_saved_payment_methods (
            user_id, payment_token, card_brand, last_four, exp_month, exp_year
        ) VALUES (
            admin_user_id, 'tok_test_drivique_001', 'VISA', '1111', 1, 2030
        );
        RAISE EXCEPTION 'Expected duplicate payment token to fail';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO billing.user_saved_payment_methods (
            user_id, payment_token, card_brand, last_four, exp_month, exp_year
        ) VALUES (
            admin_user_id, 'tok_test_invalid_month', 'MASTERCARD', '5555', 13, 2030
        );
        RAISE EXCEPTION 'Expected invalid expiration month to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO billing.user_saved_payment_methods (
            user_id, payment_token, card_brand, last_four, exp_month, exp_year
        ) VALUES (
            admin_user_id, 'tok_test_invalid_last_four', 'VISA', 'ABCD', 1, 2030
        );
        RAISE EXCEPTION 'Expected invalid last four digits to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO billing.user_saved_payment_methods (
            user_id, payment_token, card_brand, last_four, exp_month, exp_year
        ) VALUES (
            admin_user_id, '4242424242424242', 'VISA', '4242', 1, 2030
        );
        RAISE EXCEPTION 'Expected a PAN-like token to fail';
    EXCEPTION WHEN check_violation THEN NULL;
    END;

    UPDATE billing.user_saved_payment_methods
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = saved_method_id;

    SELECT updated_at INTO saved_method_updated_at
    FROM billing.user_saved_payment_methods
    WHERE id = saved_method_id;

    IF saved_method_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected saved payment method audit trigger';
    END IF;

    SELECT COUNT(*) INTO sensitive_column_count
    FROM information_schema.columns
    WHERE table_schema = 'billing'
      AND table_name = 'user_saved_payment_methods'
      AND column_name IN ('pan', 'card_number', 'cvv', 'cvc');

    IF sensitive_column_count <> 0 THEN
        RAISE EXCEPTION 'Sensitive card data columns must not exist';
    END IF;

    RAISE NOTICE 'HU-BD-36 APPROVED: tokenization, PCI safeguards, expiration validation and audit validated.';
END;
$$;

ROLLBACK;
