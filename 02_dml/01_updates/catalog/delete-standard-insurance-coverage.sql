-- El plan "Standard Protection" no forma parte de la oferta: se reasignan sus reservas al plan obligatorio y se elimina.
UPDATE rental.reservations
SET insurance_coverage_id = (SELECT id FROM catalog.insurance_coverages WHERE name = 'Protección Obligatoria')
WHERE insurance_coverage_id = (SELECT id FROM catalog.insurance_coverages WHERE name = 'Standard Protection');

DELETE FROM catalog.insurance_coverages WHERE name = 'Standard Protection';
