CREATE TABLE fleet.vehicle_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL,
    document_type VARCHAR(30) NOT NULL,
    document_number VARCHAR(100),
    file_url VARCHAR(1000) NOT NULL,
    issued_at DATE,
    expires_at DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    verified_at TIMESTAMPTZ,
    verified_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_documents_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_documents_verified_by FOREIGN KEY (verified_by) REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT chk_vehicle_documents_type CHECK (document_type IN ('SOAT', 'TECHNICAL_INSPECTION', 'REGISTRATION', 'INSURANCE', 'OTHER')),
    CONSTRAINT chk_vehicle_documents_file_url_not_blank CHECK (btrim(file_url) <> ''),
    CONSTRAINT chk_vehicle_documents_dates CHECK (expires_at IS NULL OR issued_at IS NULL OR expires_at >= issued_at)
);
