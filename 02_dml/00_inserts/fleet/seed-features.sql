-- Seed features catalog
INSERT INTO fleet.features (name, feature_group, icon, is_active)
VALUES
    ('Aire Acondicionado', 'COMFORT', 'air-conditioner', TRUE),
    ('Asientos de Cuero', 'COMFORT', 'car-seat', TRUE),
    ('Techo Panorámico', 'COMFORT', 'sunroof', TRUE),
    ('Navegación GPS', 'TECHNOLOGY', 'navigation', TRUE),
    ('Bluetooth y Manos Libres', 'TECHNOLOGY', 'bluetooth', TRUE),
    ('Apple CarPlay y Android Auto', 'TECHNOLOGY', 'smartphone', TRUE),
    ('Pantalla Táctil Multimedia', 'TECHNOLOGY', 'screen', TRUE),
    ('Frenos ABS', 'SECURITY', 'brake', TRUE),
    ('Airbags Frontales y Laterales', 'SECURITY', 'airbag', TRUE),
    ('Cámara de Reversa HD', 'SECURITY', 'camera', TRUE),
    ('Sensores de Parqueo 360', 'SECURITY', 'sensor', TRUE),
    ('Control de Estabilidad (ESP)', 'SECURITY', 'shield', TRUE),
    ('Dirección Asistida', 'STANDARD', 'steering-wheel', TRUE),
    ('Vidrios Eléctricos', 'STANDARD', 'window', TRUE),
    ('Bloqueo Central', 'STANDARD', 'lock', TRUE)
ON CONFLICT (name) DO NOTHING;

-- Seed vehicle_features associations for existing seeded vehicles
INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
SELECT v.id, f.id
FROM fleet.vehicles v
CROSS JOIN fleet.features f
WHERE v.plate = 'ABC-123' AND f.name IN ('Navegación GPS', 'Apple CarPlay y Android Auto', 'Cámara de Reversa HD', 'Frenos ABS', 'Aire Acondicionado')
ON CONFLICT (vehicle_id, feature_id) DO NOTHING;

INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
SELECT v.id, f.id
FROM fleet.vehicles v
CROSS JOIN fleet.features f
WHERE v.plate = 'GHI-789' AND f.name IN ('Asientos de Cuero', 'Apple CarPlay y Android Auto', 'Sensores de Parqueo 360', 'Frenos ABS')
ON CONFLICT (vehicle_id, feature_id) DO NOTHING;

INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
SELECT v.id, f.id
FROM fleet.vehicles v
CROSS JOIN fleet.features f
WHERE v.plate = 'PQR-678' AND f.name IN ('Techo Panorámico', 'Asientos de Cuero', 'Navegación GPS', 'Apple CarPlay y Android Auto', 'Sensores de Parqueo 360', 'Control de Estabilidad (ESP)')
ON CONFLICT (vehicle_id, feature_id) DO NOTHING;
