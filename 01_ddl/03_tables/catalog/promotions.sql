CREATE TABLE catalog.promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    offer_type VARCHAR(20) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value NUMERIC(12, 2) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    minimum_rental_days INT NOT NULL DEFAULT 1,
    max_uses_limit INT,
    current_uses_count INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_promotions_code_not_blank CHECK (btrim(code) <> ''),
    CONSTRAINT chk_promotions_offer_type CHECK (offer_type IN ('PROMOTION', 'COUPON')),
    CONSTRAINT chk_promotions_discount_type CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')),
    CONSTRAINT chk_promotions_discount_value_positive CHECK (discount_value > 0),
    CONSTRAINT chk_promotions_percentage_maximum CHECK (discount_type <> 'PERCENTAGE' OR discount_value <= 100),
    CONSTRAINT chk_promotions_date_range CHECK (ends_at > starts_at),
    CONSTRAINT chk_promotions_minimum_rental_days CHECK (minimum_rental_days >= 1),
    CONSTRAINT chk_promotions_use_counts CHECK (
        current_uses_count >= 0
        AND (max_uses_limit IS NULL OR max_uses_limit >= current_uses_count)
    )
);
