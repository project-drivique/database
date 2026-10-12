CREATE TABLE IF NOT EXISTS support.notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(60) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    subject_template VARCHAR(250) NOT NULL,
    body_template TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_notification_templates_channel
        CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    CONSTRAINT chk_notification_templates_event_type
        CHECK (event_type IN ('REGISTRATION', 'PAYMENT', 'RESERVATION', 'CANCELLATION', 'CONTRACT', 'DELIVERY', 'RETURN', 'DOCUMENT', 'INCIDENT', 'SECURITY', 'PROMOTION', 'GENERAL')),
    CONSTRAINT chk_notification_templates_code_not_blank
        CHECK (btrim(code) <> ''),
    CONSTRAINT chk_notification_templates_name_not_blank
        CHECK (btrim(name) <> ''),
    CONSTRAINT chk_notification_templates_body_not_blank
        CHECK (btrim(body_template) <> '')
);

CREATE TRIGGER trg_notification_templates_set_updated_at
    BEFORE UPDATE ON support.notification_templates
    FOR EACH ROW
    EXECUTE FUNCTION core.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_notification_templates_event_channel
    ON support.notification_templates (event_type, channel)
    WHERE is_active = TRUE;
