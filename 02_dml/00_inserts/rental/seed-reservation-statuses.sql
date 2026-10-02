INSERT INTO rental.reservation_statuses (code, name, blocks_availability) VALUES
    ('PENDING_PAYMENT', 'Pending payment', TRUE),
    ('CONFIRMED', 'Confirmed', TRUE),
    ('IN_PROGRESS', 'In progress', TRUE),
    ('COMPLETED', 'Completed', FALSE),
    ('CANCELLED_BY_TIMEOUT', 'Cancelled by timeout', FALSE),
    ('CANCELLED_BY_USER', 'Cancelled by user', FALSE),
    ('REJECTED', 'Rejected', FALSE);
