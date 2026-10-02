BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    promotion_id UUID;
    promotion_updated_at TIMESTAMPTZ;
BEGIN
    SELECT id INTO admin_user_id
    FROM iam.users
    WHERE email = 'admin@drivique.com';

    IF admin_user_id IS NULL THEN
        RAISE EXCEPTION 'Expected admin user seed';
    END IF;

    INSERT INTO catalog.promotions (
        code, offer_type, discount_type, discount_value,
        starts_at, ends_at, minimum_rental_days, max_uses_limit
    ) VALUES (
        'WELCOME25', 'COUPON', 'PERCENTAGE', 25.00,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 2, 100
    ) RETURNING id INTO promotion_id;

    INSERT INTO catalog.user_coupon_usages (
        promotion_id, user_id, discount_amount
    ) VALUES (
        promotion_id, admin_user_id, 50000.00
    );

    BEGIN
        INSERT INTO catalog.promotions (
            code, offer_type, discount_type, discount_value,
            starts_at, ends_at
        ) VALUES (
            'WELCOME25', 'PROMOTION', 'FIXED_AMOUNT', 10000.00,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'
        );
        RAISE EXCEPTION 'Expected duplicate promotion code to fail';
    EXCEPTION
        WHEN unique_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.promotions (
            code, offer_type, discount_type, discount_value,
            starts_at, ends_at
        ) VALUES (
            'INVALID-DATES', 'PROMOTION', 'FIXED_AMOUNT', 10000.00,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP - INTERVAL '1 day'
        );
        RAISE EXCEPTION 'Expected invalid promotion dates to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.promotions (
            code, offer_type, discount_type, discount_value,
            starts_at, ends_at
        ) VALUES (
            'INVALID-PERCENTAGE', 'COUPON', 'PERCENTAGE', 101.00,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'
        );
        RAISE EXCEPTION 'Expected percentage above 100 to fail';
    EXCEPTION
        WHEN check_violation THEN NULL;
    END;

    BEGIN
        INSERT INTO catalog.user_coupon_usages (
            promotion_id, user_id, discount_amount
        ) VALUES (
            '00000000-0000-0000-0000-000000000000', admin_user_id, 1000.00
        );
        RAISE EXCEPTION 'Expected coupon usage with unknown promotion to fail';
    EXCEPTION
        WHEN foreign_key_violation THEN NULL;
    END;

    UPDATE catalog.promotions
    SET updated_at = '2000-01-01 00:00:00+00'
    WHERE id = promotion_id;

    SELECT updated_at INTO promotion_updated_at
    FROM catalog.promotions
    WHERE id = promotion_id;

    IF promotion_updated_at <= '2000-01-01 00:00:00+00'::TIMESTAMPTZ THEN
        RAISE EXCEPTION 'Expected promotions updated_at trigger to overwrite stale timestamp';
    END IF;

    RAISE NOTICE 'HU-BD-25 APPROVED: promotion rules, coupon usage, indexes and audit timestamp validated.';
END;
$$;

ROLLBACK;
