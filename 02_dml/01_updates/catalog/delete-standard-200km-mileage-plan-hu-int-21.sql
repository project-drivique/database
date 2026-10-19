-- El plan "Standard 200 km" ($0, incluido en la tarifa) no forma parte de la oferta: se reasignan sus reservas
-- (si las hubiera) al plan "Extended 400 km" y se elimina.
UPDATE rental.reservations
SET mileage_plan_id = (SELECT id FROM catalog.mileage_plans WHERE name = 'Extended 400 km')
WHERE mileage_plan_id = (SELECT id FROM catalog.mileage_plans WHERE name = 'Standard 200 km');

DELETE FROM catalog.mileage_plans WHERE name = 'Standard 200 km';
