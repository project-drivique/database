INSERT INTO location.departments (name) VALUES
    ('Antioquia'),
    ('Atlántico'),
    ('Bogotá D.C.'),
    ('Bolívar'),
    ('Boyacá'),
    ('Caldas'),
    ('Cesar'),
    ('Córdoba'),
    ('Cundinamarca'),
    ('Huila'),
    ('Magdalena'),
    ('Meta'),
    ('Nariño'),
    ('Norte de Santander'),
    ('Quindío'),
    ('Risaralda'),
    ('Santander'),
    ('Tolima'),
    ('Valle del Cauca');

INSERT INTO location.cities (department_id, name, has_airport, has_terminal)
SELECT departments.id, seeded_cities.name, seeded_cities.has_airport, seeded_cities.has_terminal
FROM (
    VALUES
        ('Antioquia', 'Medellín', TRUE, TRUE),
        ('Antioquia', 'Rionegro', TRUE, FALSE),
        ('Atlántico', 'Barranquilla', TRUE, TRUE),
        ('Bogotá D.C.', 'Bogotá', TRUE, TRUE),
        ('Bolívar', 'Cartagena', TRUE, TRUE),
        ('Boyacá', 'Tunja', FALSE, TRUE),
        ('Caldas', 'Manizales', TRUE, TRUE),
        ('Cesar', 'Valledupar', TRUE, TRUE),
        ('Córdoba', 'Montería', TRUE, TRUE),
        ('Cundinamarca', 'Soacha', FALSE, TRUE),
        ('Huila', 'Neiva', TRUE, TRUE),
        ('Magdalena', 'Santa Marta', TRUE, TRUE),
        ('Meta', 'Villavicencio', TRUE, TRUE),
        ('Nariño', 'Pasto', TRUE, TRUE),
        ('Norte de Santander', 'Cúcuta', TRUE, TRUE),
        ('Quindío', 'Armenia', TRUE, TRUE),
        ('Risaralda', 'Pereira', TRUE, TRUE),
        ('Santander', 'Bucaramanga', TRUE, TRUE),
        ('Tolima', 'Ibagué', TRUE, TRUE),
        ('Valle del Cauca', 'Cali', TRUE, TRUE)
) AS seeded_cities(department_name, name, has_airport, has_terminal)
JOIN location.departments ON departments.name = seeded_cities.department_name;
