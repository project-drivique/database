CREATE UNIQUE INDEX idx_promotions_code ON catalog.promotions (code);
CREATE INDEX idx_promotions_dates ON catalog.promotions (starts_at, ends_at);
CREATE INDEX idx_user_coupon_usages_user ON catalog.user_coupon_usages (user_id, used_at DESC);
