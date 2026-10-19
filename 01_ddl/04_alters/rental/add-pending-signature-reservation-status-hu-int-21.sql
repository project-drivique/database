-- ==============================================================================
-- HU-INT-21: Agregar estado PENDING_SIGNATURE a rental.reservation_statuses
-- Permite bloquear disponibilidad y exigir firma de contrato antes de confirmar.
-- ==============================================================================

INSERT INTO rental.reservation_statuses (id, code, name, blocks_availability, created_at, updated_at)
VALUES (gen_random_uuid(), 'PENDING_SIGNATURE', 'Pendiente de firma de contrato', TRUE, now(), now())
ON CONFLICT (code) DO NOTHING;
