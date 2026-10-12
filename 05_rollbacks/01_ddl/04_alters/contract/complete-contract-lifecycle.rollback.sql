ALTER TABLE contract.inspection_checklist_answers DROP COLUMN IF EXISTS evidence_sha256;

ALTER TABLE contract.vehicle_inspections
    DROP CONSTRAINT IF EXISTS chk_vehicle_inspections_charges_nonnegative,
    DROP COLUMN IF EXISTS total_charge,
    DROP COLUMN IF EXISTS damage_charge,
    DROP COLUMN IF EXISTS fuel_charge,
    DROP COLUMN IF EXISTS mileage_charge;

ALTER TABLE contract.rental_contracts
    DROP CONSTRAINT IF EXISTS chk_rental_contracts_additional_charges_nonnegative,
    DROP COLUMN IF EXISTS additional_charges,
    DROP COLUMN IF EXISTS pdf_sha256,
    DROP COLUMN IF EXISTS signature_sha256,
    DROP COLUMN IF EXISTS signer_ip_hash,
    DROP COLUMN IF EXISTS consent_text,
    DROP COLUMN IF EXISTS document_version;
