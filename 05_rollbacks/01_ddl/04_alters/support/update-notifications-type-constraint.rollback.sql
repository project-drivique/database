ALTER TABLE support.notifications DROP CONSTRAINT IF EXISTS chk_notifications_type;
ALTER TABLE support.notifications ADD CONSTRAINT chk_notifications_type CHECK (
    type IN ('GENERAL', 'SECURITY', 'RESERVATION', 'PROMOTION')
);

ALTER TABLE support.notifications DROP CONSTRAINT IF EXISTS chk_notifications_event_type;
ALTER TABLE support.notifications ADD CONSTRAINT chk_notifications_event_type CHECK (
    event_type IS NULL OR event_type IN (
        'REGISTRATION', 'PAYMENT', 'RESERVATION', 'CANCELLATION', 'CONTRACT', 'DELIVERY', 'RETURN', 
        'DOCUMENT', 'INCIDENT', 'SECURITY', 'PROMOTION', 'GENERAL'
    )
);
