CREATE TABLE support.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    type VARCHAR(30) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    reference_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_notifications_channel CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    CONSTRAINT chk_notifications_type CHECK (type IN ('GENERAL', 'SECURITY', 'RESERVATION', 'PROMOTION')),
    CONSTRAINT chk_notifications_subject_not_blank CHECK (btrim(subject) <> ''),
    CONSTRAINT chk_notifications_message_not_blank CHECK (btrim(message) <> '')
);
