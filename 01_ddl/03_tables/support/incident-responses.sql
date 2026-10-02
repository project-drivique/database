CREATE TABLE support.incident_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_report_id UUID NOT NULL,
    author_user_id UUID NOT NULL,
    message TEXT NOT NULL,
    attachment_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incident_responses_report FOREIGN KEY (incident_report_id) REFERENCES support.incident_reports (id) ON DELETE CASCADE,
    CONSTRAINT fk_incident_responses_author FOREIGN KEY (author_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_incident_responses_message_not_blank CHECK (btrim(message) <> ''),
    CONSTRAINT chk_incident_responses_attachment_url_not_blank CHECK (attachment_url IS NULL OR btrim(attachment_url) <> '')
);
