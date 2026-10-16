-- Marca cuándo se avisó a los clientes de una promoción vigente (para avisar una sola vez)
ALTER TABLE catalog.promotions ADD COLUMN IF NOT EXISTS notification_sent_at timestamptz;
