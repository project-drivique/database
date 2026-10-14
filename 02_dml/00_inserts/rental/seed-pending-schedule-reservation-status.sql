INSERT INTO rental.reservation_statuses (code, name, blocks_availability)
VALUES ('PENDING_SCHEDULE', 'Pending branch schedule', TRUE)
ON CONFLICT (code) DO UPDATE
SET blocks_availability = TRUE;
