-- La oferta comercial son dos planes de protección: la obligatoria (base de toda reserva) y la total.
UPDATE catalog.insurance_coverages
SET name = 'Protección Obligatoria',
    daily_rate = 29000.00,
    description = 'Protección básica obligatoria incluida en toda reserva.'
WHERE name = 'Basic Protection';

UPDATE catalog.insurance_coverages
SET name = 'Protección Total',
    daily_rate = 67000.00,
    description = 'Cobertura total contra todo riesgo con cero deducible.'
WHERE name = 'Premium Protection';

UPDATE catalog.insurance_coverages
SET is_active = FALSE
WHERE name = 'Standard Protection';
