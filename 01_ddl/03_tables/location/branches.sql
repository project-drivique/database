CREATE TABLE location.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city_id UUID NOT NULL,
    phone VARCHAR(30) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    allows_cash_payment BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_branches_city
        FOREIGN KEY (city_id) REFERENCES location.cities (id),
    CONSTRAINT uq_branches_name UNIQUE (name),
    CONSTRAINT chk_branches_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_branches_address_not_blank CHECK (btrim(address) <> ''),
    CONSTRAINT chk_branches_phone_not_blank CHECK (btrim(phone) <> ''),
    CONSTRAINT chk_branches_business_hours CHECK (closing_time > opening_time)
);
