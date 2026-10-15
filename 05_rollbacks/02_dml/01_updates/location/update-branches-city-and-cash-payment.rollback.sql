UPDATE location.branches
SET city_id = (SELECT id FROM location.cities WHERE name = 'Rionegro')
WHERE name = 'Drivique Medellín Aeropuerto';

UPDATE location.branches
SET allows_cash_payment = (name <> 'Drivique Medellín Aeropuerto');
