INSERT INTO catalog.mileage_plans (name, included_km, daily_rate, extra_km_rate, is_active)
SELECT 'Standard 200 km', 200, 0.00, 850.00, TRUE
WHERE NOT EXISTS (SELECT 1 FROM catalog.mileage_plans WHERE name = 'Standard 200 km');
