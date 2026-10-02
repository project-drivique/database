INSERT INTO billing.payment_methods (code, name) VALUES
    ('CASH', 'Cash'),
    ('CREDIT_CARD', 'Credit card'),
    ('DEBIT_CARD', 'Debit card'),
    ('PSE', 'PSE'),
    ('NEQUI', 'Nequi'),
    ('BANCOLOMBIA', 'Bancolombia');

INSERT INTO billing.payment_statuses (code, name, is_final) VALUES
    ('PENDING', 'Pending', FALSE),
    ('APPROVED', 'Approved', TRUE),
    ('DECLINED', 'Declined', TRUE),
    ('REFUNDED', 'Refunded', TRUE),
    ('VOIDED', 'Voided', TRUE);
