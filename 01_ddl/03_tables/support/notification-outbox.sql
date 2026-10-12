CREATE TABLE IF NOT EXISTS support.notification_outbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    next_retry_at TIMESTAMPTZ,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    idempotency_key VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_outbox_notification
        FOREIGN KEY (notification_id) REFERENCES support.notifications (id) ON DELETE CASCADE,
    CONSTRAINT chk_notification_outbox_channel
        CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    CONSTRAINT chk_notification_outbox_status
        CHECK (status IN ('PENDING', 'PROCESSING', 'SENT', 'FAILED', 'DEAD_LETTER')),
    CONSTRAINT chk_notification_outbox_retry_count
        CHECK (retry_count >= 0),
    CONSTRAINT chk_notification_outbox_max_retries
        CHECK (max_retries >= 0),
    CONSTRAINT chk_notification_outbox_recipient_not_blank
        CHECK (btrim(recipient) <> ''),
    CONSTRAINT uq_notification_outbox_idempotency
        UNIQUE (idempotency_key)
);

CREATE TRIGGER trg_notification_outbox_set_updated_at
    BEFORE UPDATE ON support.notification_outbox
    FOR EACH ROW
    EXECUTE FUNCTION core.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_notification_outbox_pending
    ON support.notification_outbox (status, next_retry_at)
    WHERE status IN ('PENDING', 'FAILED');

CREATE INDEX IF NOT EXISTS idx_notification_outbox_notification
    ON support.notification_outbox (notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_outbox_channel
    ON support.notification_outbox (channel);
