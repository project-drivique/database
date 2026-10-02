CREATE TABLE rental.reservation_promotions (
    reservation_id UUID NOT NULL,
    promotion_id UUID NOT NULL,
    discount_applied NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reservation_promotions
        PRIMARY KEY (reservation_id, promotion_id),
    CONSTRAINT fk_reservation_promotions_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_promotions_promotion
        FOREIGN KEY (promotion_id) REFERENCES catalog.promotions (id) ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_promotions_discount_applied_nonnegative
        CHECK (discount_applied >= 0)
);
