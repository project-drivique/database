INSERT INTO catalog.insurance_coverages (name, description, daily_rate, is_active)
VALUES ('Standard Protection', 'Reduces the customer liability for covered events.', 45000.00, FALSE)
ON CONFLICT DO NOTHING;
