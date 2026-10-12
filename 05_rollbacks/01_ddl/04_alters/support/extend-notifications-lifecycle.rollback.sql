DROP INDEX IF EXISTS support.uq_notifications_user_idempotency;
DROP INDEX IF EXISTS support.idx_notifications_user_criticality;
DROP INDEX IF EXISTS support.idx_notifications_event_type;

ALTER TABLE support.notifications
    DROP CONSTRAINT IF EXISTS chk_notifications_criticality,
    DROP CONSTRAINT IF EXISTS chk_notifications_event_type,
    DROP COLUMN IF EXISTS idempotency_key,
    DROP COLUMN IF EXISTS metadata,
    DROP COLUMN IF EXISTS criticality,
    DROP COLUMN IF EXISTS event_type;
