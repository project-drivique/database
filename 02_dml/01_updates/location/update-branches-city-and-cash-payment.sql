-- La sucursal "Drivique Medellín Aeropuerto" pertenece a la ciudad de Medellín (coherencia nombre/ciudad).
UPDATE location.branches
SET city_id = (SELECT id FROM location.cities WHERE name = 'Medellín')
WHERE name = 'Drivique Medellín Aeropuerto';

-- Solo las sucursales con punto de caja físico reciben pagos en efectivo; el resto opera únicamente con Wompi.
UPDATE location.branches
SET allows_cash_payment = (name IN ('Drivique Bogotá Centro', 'Drivique Medellín Aeropuerto', 'Drivique Cali Centro'));
