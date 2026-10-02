CREATE TABLE catalog.user_coupon_usages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promotion_id UUID NOT NULL,
    user_id UUID NOT NULL,
    used_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discount_amount NUMERIC(12, 2) NOT NULL,
    CONSTRAINT fk_user_coupon_usages_promotion
        FOREIGN KEY (promotion_id) REFERENCES catalog.promotions (id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_coupon_usages_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_user_coupon_usages_discount_amount_nonnegative CHECK (discount_amount >= 0)
);
