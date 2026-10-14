INSERT INTO rental.reservation_statuses (code, name, blocks_availability)
VALUES ('PENDING_DOCUMENT_REVIEW', 'Pending document review', TRUE)
ON CONFLICT (code) DO UPDATE
SET blocks_availability = TRUE;
