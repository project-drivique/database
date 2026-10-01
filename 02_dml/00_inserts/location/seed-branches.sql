INSERT INTO location.branches (
    name,
    address,
    city_id,
    phone,
    opening_time,
    closing_time,
    allows_cash_payment
)
SELECT
    seeded_branches.name,
    seeded_branches.address,
    cities.id,
    seeded_branches.phone,
    seeded_branches.opening_time,
    seeded_branches.closing_time,
    seeded_branches.allows_cash_payment
FROM (
    VALUES
        ('Drivique Bogotá Centro', 'Carrera 7 # 72-41', 'Bogotá', '+57 601 555 0101', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Medellín Centro', 'Calle 10 # 43C-30', 'Medellín', '+57 604 555 0102', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Medellín Aeropuerto', 'Aeropuerto Internacional José María Córdova', 'Rionegro', '+57 604 555 0103', '06:00'::TIME, '22:00'::TIME, FALSE),
        ('Drivique Cali Centro', 'Avenida 6N # 24N-12', 'Cali', '+57 602 555 0104', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Barranquilla Centro', 'Carrera 53 # 80-198', 'Barranquilla', '+57 605 555 0105', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Cartagena Centro', 'Avenida San Martín # 8-67', 'Cartagena', '+57 605 555 0106', '08:00'::TIME, '18:00'::TIME, TRUE)
) AS seeded_branches(name, address, city_name, phone, opening_time, closing_time, allows_cash_payment)
JOIN location.cities ON cities.name = seeded_branches.city_name;
