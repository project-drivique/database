UPDATE catalog.insurance_coverages SET name = 'Basic Protection', daily_rate = 0.00, description = 'Base protection included with every rental.' WHERE name = 'Protección Obligatoria';
UPDATE catalog.insurance_coverages SET name = 'Premium Protection', daily_rate = 80000.00, description = 'Provides the broadest available protection and lower liability.' WHERE name = 'Protección Total';
UPDATE catalog.insurance_coverages SET is_active = TRUE WHERE name = 'Standard Protection';
