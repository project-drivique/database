CREATE TABLE IF NOT EXISTS support.notification_delivery_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outbox_id UUID NOT NULL,
    attempt_number INTEGER NOT NULL,
    provider VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    provider_message_id VARCHAR(100),
    error_code VARCHAR(50),
    error_message TEXT,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_attempts_outbox
        FOREIGN KEY (outbox_id) REFERENCES support.notification_outbox (id) ON DELETE CASCADE,
    CONSTRAINT chk_notification_attempts_number
        CHECK (attempt_number > 0),
    CONSTRAINT chk_notification_attempts_status
        CHECK (status IN ('SUCCESS', 'FAILED', 'REJECTED', 'TIMEOUT')),
    CONSTRAINT chk_notification_attempts_provider_not_blank
        CHECK (btrim(provider) <> ''),
    CONSTRAINT uq_notification_delivery_attempts_number
        UNIQUE (outbox_id, attempt_number)
);

CREATE INDEX IF NOT EXISTS idx_notification_attempts_outbox
    ON support.notification_delivery_attempts (outbox_id);

CREATE INDEX IF NOT EXISTS idx_notification_attempts_provider_status
    ON support.notification_delivery_attempts (provider, status);
