ALTER TABLE support.incident_reports
    ADD COLUMN IF NOT EXISTS category VARCHAR(20) NOT NULL DEFAULT 'OTHER',
    ADD COLUMN IF NOT EXISTS branch_id UUID,
    ADD COLUMN IF NOT EXISTS assigned_to_user_id UUID,
    ADD COLUMN IF NOT EXISTS sla_due_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ;

ALTER TABLE support.incident_reports
    ADD CONSTRAINT chk_incident_reports_category CHECK (category IN ('RESERVATION', 'VEHICLE', 'PAYMENT', 'OTHER')),
    ADD CONSTRAINT fk_incident_reports_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_incident_reports_assigned_to FOREIGN KEY (assigned_to_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_incident_reports_branch ON support.incident_reports (branch_id);
CREATE INDEX IF NOT EXISTS idx_incident_reports_assigned_to ON support.incident_reports (assigned_to_user_id);

CREATE TABLE IF NOT EXISTS support.incident_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_report_id UUID NOT NULL,
    response_id UUID,
    uploaded_by_user_id UUID NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    storage_path VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incident_attachments_report FOREIGN KEY (incident_report_id) REFERENCES support.incident_reports (id) ON DELETE CASCADE,
    CONSTRAINT fk_incident_attachments_response FOREIGN KEY (response_id) REFERENCES support.incident_responses (id) ON DELETE CASCADE,
    CONSTRAINT fk_incident_attachments_user FOREIGN KEY (uploaded_by_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_incident_attachments_size CHECK (size_bytes > 0)
);

CREATE INDEX IF NOT EXISTS idx_incident_attachments_report ON support.incident_attachments (incident_report_id);

CREATE TABLE IF NOT EXISTS support.incident_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_report_id UUID NOT NULL,
    from_status VARCHAR(20),
    to_status VARCHAR(20) NOT NULL,
    changed_by_user_id UUID NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incident_status_history_report FOREIGN KEY (incident_report_id) REFERENCES support.incident_reports (id) ON DELETE CASCADE,
    CONSTRAINT fk_incident_status_history_user FOREIGN KEY (changed_by_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_incident_status_history_to CHECK (to_status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'CLOSED'))
);

CREATE INDEX IF NOT EXISTS idx_incident_status_history_report ON support.incident_status_history (incident_report_id, created_at);
