INSERT INTO catalog.promotions (code, offer_type, discount_type, discount_value, starts_at, ends_at, minimum_rental_days, is_active)
VALUES 
    ('BIENVENIDO10', 'COUPON', 'PERCENTAGE', 10.00, '2026-01-01 00:00:00Z', '2027-12-31 23:59:59Z', 1, true),
    ('DRIVIQUE50K', 'COUPON', 'FIXED_AMOUNT', 50000.00, '2026-01-01 00:00:00Z', '2027-12-31 23:59:59Z', 1, true),
    ('SUV20', 'PROMOTION', 'PERCENTAGE', 20.00, '2026-01-01 00:00:00Z', '2027-12-31 23:59:59Z', 1, true)
ON CONFLICT (code) DO NOTHING;
