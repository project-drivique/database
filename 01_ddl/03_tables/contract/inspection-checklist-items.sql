CREATE TABLE contract.inspection_checklist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_inspection_checklist_items_name
        UNIQUE (name),
    CONSTRAINT chk_inspection_checklist_items_name_not_blank
        CHECK (btrim(name) <> ''),
    CONSTRAINT chk_inspection_checklist_items_description_not_blank
        CHECK (description IS NULL OR btrim(description) <> '')
);
