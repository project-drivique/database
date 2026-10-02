CREATE TABLE contract.rental_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_number VARCHAR(30) NOT NULL,
    reservation_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    status_id UUID NOT NULL,
    pickup_branch_id UUID NOT NULL,
    return_branch_id UUID NOT NULL,
    scheduled_start_at TIMESTAMPTZ NOT NULL,
    scheduled_end_at TIMESTAMPTZ NOT NULL,
    base_amount NUMERIC(12, 2) NOT NULL,
    security_deposit NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    signature_url VARCHAR(1000),
    signature_stroke_data JSONB,
    signed_city_id UUID,
    signed_at TIMESTAMPTZ,
    pdf_url VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rental_contracts_contract_number UNIQUE (contract_number),
    CONSTRAINT uq_rental_contracts_reservation UNIQUE (reservation_id),
    CONSTRAINT fk_rental_contracts_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_rental_contracts_customer
        FOREIGN KEY (customer_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_status
        FOREIGN KEY (status_id) REFERENCES contract.contract_statuses (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_pickup_branch
        FOREIGN KEY (pickup_branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_return_branch
        FOREIGN KEY (return_branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_signed_city
        FOREIGN KEY (signed_city_id) REFERENCES location.cities (id) ON DELETE RESTRICT,
    CONSTRAINT chk_rental_contracts_contract_number_not_blank CHECK (btrim(contract_number) <> ''),
    CONSTRAINT chk_rental_contracts_scheduled_period CHECK (scheduled_end_at > scheduled_start_at),
    CONSTRAINT chk_rental_contracts_base_amount_nonnegative CHECK (base_amount >= 0),
    CONSTRAINT chk_rental_contracts_security_deposit_nonnegative CHECK (security_deposit >= 0),
    CONSTRAINT chk_rental_contracts_signature_url_not_blank CHECK (signature_url IS NULL OR btrim(signature_url) <> ''),
    CONSTRAINT chk_rental_contracts_pdf_url_not_blank CHECK (pdf_url IS NULL OR btrim(pdf_url) <> '')
);
