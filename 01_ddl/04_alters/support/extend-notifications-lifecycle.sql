ALTER TABLE support.notifications
    ADD COLUMN IF NOT EXISTS event_type VARCHAR(50),
    ADD COLUMN IF NOT EXISTS criticality VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    ADD COLUMN IF NOT EXISTS metadata JSONB,
    ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(100);

ALTER TABLE support.notifications
    DROP CONSTRAINT IF EXISTS chk_notifications_event_type,
    ADD CONSTRAINT chk_notifications_event_type
        CHECK (event_type IS NULL OR event_type IN ('REGISTRATION', 'PAYMENT', 'RESERVATION', 'CANCELLATION', 'CONTRACT', 'DELIVERY', 'RETURN', 'DOCUMENT', 'INCIDENT', 'SECURITY', 'PROMOTION', 'GENERAL'));

ALTER TABLE support.notifications
    DROP CONSTRAINT IF EXISTS chk_notifications_criticality,
    ADD CONSTRAINT chk_notifications_criticality
        CHECK (criticality IN ('CRITICAL', 'HIGH', 'NORMAL', 'LOW'));

CREATE INDEX IF NOT EXISTS idx_notifications_event_type
    ON support.notifications (event_type);

CREATE INDEX IF NOT EXISTS idx_notifications_user_criticality
    ON support.notifications (user_id, criticality, is_read);

CREATE UNIQUE INDEX IF NOT EXISTS uq_notifications_user_idempotency
    ON support.notifications (user_id, idempotency_key)
    WHERE idempotency_key IS NOT NULL;
