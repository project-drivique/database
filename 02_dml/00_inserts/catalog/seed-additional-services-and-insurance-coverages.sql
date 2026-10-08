INSERT INTO catalog.additional_services (name, daily_rate) VALUES
    ('Baby Seat', 25000.00),
    ('GPS Navigation', 18000.00),
    ('Mobile Wi-Fi', 22000.00),
    ('Additional Driver', 30000.00),
    ('Roadside Assistance', 15000.00)
ON CONFLICT (name) DO NOTHING;

INSERT INTO catalog.insurance_coverages (name, daily_rate, description) VALUES
    ('Basic Protection', 0.00, 'Base protection included with every rental.'),
    ('Standard Protection', 45000.00, 'Reduces the customer liability for covered events.'),
    ('Premium Protection', 80000.00, 'Provides the broadest available protection and lower liability.')
ON CONFLICT (name) DO NOTHING;
