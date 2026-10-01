INSERT INTO fleet.vehicle_brands (name) VALUES
    ('Chevrolet'),
    ('Renault'),
    ('Mazda'),
    ('Toyota'),
    ('Kia'),
    ('Nissan'),
    ('Hyundai'),
    ('Ford'),
    ('Volkswagen'),
    ('BMW'),
    ('Mercedes-Benz');

INSERT INTO fleet.transmission_types (code, name) VALUES
    ('MANUAL', 'Manual'),
    ('AUTOMATIC', 'Automatic');

INSERT INTO fleet.fuel_types (code, name) VALUES
    ('GASOLINE', 'Gasoline'),
    ('DIESEL', 'Diesel'),
    ('ELECTRIC', 'Electric'),
    ('HYBRID', 'Hybrid');

INSERT INTO fleet.vehicle_statuses (code, name, allows_reservation) VALUES
    ('AVAILABLE', 'Available', TRUE),
    ('RENTED', 'Rented', FALSE),
    ('MAINTENANCE', 'Maintenance', FALSE),
    ('INACTIVE', 'Inactive', FALSE);
