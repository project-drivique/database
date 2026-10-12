ALTER TABLE contract.rental_contracts
    ADD COLUMN document_version VARCHAR(30) NOT NULL DEFAULT 'v1.0',
    ADD COLUMN consent_text VARCHAR(500),
    ADD COLUMN signer_ip_hash VARCHAR(64),
    ADD COLUMN signature_sha256 VARCHAR(64),
    ADD COLUMN pdf_sha256 VARCHAR(64),
    ADD COLUMN additional_charges NUMERIC(12, 2) NOT NULL DEFAULT 0.00;

ALTER TABLE contract.rental_contracts
    ADD CONSTRAINT chk_rental_contracts_additional_charges_nonnegative CHECK (additional_charges >= 0);

ALTER TABLE contract.vehicle_inspections
    ADD COLUMN mileage_charge NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    ADD COLUMN fuel_charge NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    ADD COLUMN damage_charge NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    ADD COLUMN total_charge NUMERIC(12, 2) NOT NULL DEFAULT 0.00;

ALTER TABLE contract.vehicle_inspections
    ADD CONSTRAINT chk_vehicle_inspections_charges_nonnegative
        CHECK (mileage_charge >= 0 AND fuel_charge >= 0 AND damage_charge >= 0 AND total_charge >= 0);

ALTER TABLE contract.inspection_checklist_answers
    ADD COLUMN evidence_sha256 VARCHAR(64);
