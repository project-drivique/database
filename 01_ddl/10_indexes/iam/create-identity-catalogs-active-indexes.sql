CREATE INDEX idx_document_types_active ON iam.document_types (code) WHERE is_active;
CREATE INDEX idx_nationalities_active ON iam.nationalities (name) WHERE is_active;
CREATE INDEX idx_document_statuses_active ON iam.document_statuses (code) WHERE is_active;
