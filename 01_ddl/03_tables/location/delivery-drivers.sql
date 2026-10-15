CREATE TABLE location.delivery_drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(254),
    phone VARCHAR(30),
    document_type VARCHAR(10) NOT NULL DEFAULT 'CC',
    document_number VARCHAR(40) NOT NULL,
    license_number VARCHAR(40),
    license_category VARCHAR(5),
    license_expires_on DATE,
    vehicle_description VARCHAR(120),
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_drivers_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id),
    CONSTRAINT uq_delivery_drivers_branch_document UNIQUE (branch_id, document_number),
    CONSTRAINT chk_delivery_drivers_name_not_blank CHECK (btrim(full_name) <> ''),
    CONSTRAINT chk_delivery_drivers_document_not_blank CHECK (btrim(document_number) <> ''),
    CONSTRAINT chk_delivery_drivers_status CHECK (status IN ('AVAILABLE', 'ON_ROUTE', 'INACTIVE'))
);

CREATE INDEX idx_delivery_drivers_branch ON location.delivery_drivers (branch_id);

ALTER TABLE rental.reservation_delivery_points
    ADD COLUMN driver_id UUID,
    ADD COLUMN delivery_pin VARCHAR(4),
    ADD COLUMN delivery_status VARCHAR(12) NOT NULL DEFAULT 'PENDING',
    ADD COLUMN delivered_at TIMESTAMPTZ;

ALTER TABLE rental.reservation_delivery_points
    ADD CONSTRAINT fk_reservation_delivery_points_driver FOREIGN KEY (driver_id) REFERENCES location.delivery_drivers (id),
    ADD CONSTRAINT chk_reservation_delivery_points_delivery_status CHECK (delivery_status IN ('PENDING', 'ASSIGNED', 'COMPLETED'));

GRANT SELECT, INSERT, UPDATE, DELETE ON location.delivery_drivers TO drivique_app;
