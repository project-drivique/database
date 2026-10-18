-- ROLLBACK HU-INT-21: quitar el estado PENDING_SIGNATURE (falla si todavía hay reservas en ese estado)
DELETE FROM rental.reservation_statuses WHERE code = 'PENDING_SIGNATURE';
