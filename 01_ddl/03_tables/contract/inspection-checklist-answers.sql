CREATE TABLE contract.inspection_checklist_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspection_id UUID NOT NULL,
    checklist_item_id UUID NOT NULL,
    is_compliant BOOLEAN NOT NULL DEFAULT TRUE,
    observation TEXT,
    evidence_photo_url VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_inspection_checklist_answers_item
        UNIQUE (inspection_id, checklist_item_id),
    CONSTRAINT fk_inspection_checklist_answers_inspection
        FOREIGN KEY (inspection_id) REFERENCES contract.vehicle_inspections (id) ON DELETE CASCADE,
    CONSTRAINT fk_inspection_checklist_answers_item
        FOREIGN KEY (checklist_item_id) REFERENCES contract.inspection_checklist_items (id) ON DELETE RESTRICT,
    CONSTRAINT chk_inspection_checklist_answers_observation_not_blank
        CHECK (observation IS NULL OR btrim(observation) <> ''),
    CONSTRAINT chk_inspection_checklist_answers_evidence_url_not_blank
        CHECK (evidence_photo_url IS NULL OR btrim(evidence_photo_url) <> '')
);
