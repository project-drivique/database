CREATE TABLE rental.rental_extension_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL,
    requested_return_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    additional_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rental_extension_requests_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_rental_extension_requests_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT chk_rental_extension_requests_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT chk_rental_extension_requests_additional_amount_nonnegative
        CHECK (additional_amount >= 0)
);
