ALTER TABLE support.notification_templates DROP CONSTRAINT IF EXISTS chk_notification_templates_event_type;
ALTER TABLE support.notification_templates
    ADD CONSTRAINT chk_notification_templates_event_type
    CHECK (event_type IN ('REGISTRATION', 'PAYMENT', 'RESERVATION', 'CANCELLATION', 'CONTRACT', 'DELIVERY', 'RETURN', 'DOCUMENT', 'INCIDENT', 'SECURITY', 'PROMOTION', 'GENERAL'));
