-- ==============================================================================
-- Flyway Migration: V5__categorias_vehiculos_caracteristicas_disponibilidad.sql
-- Historia: HU-BD-05 - Persistir Categorías, Vehículos, Características y Disponibilidad
-- ==============================================================================

-- 1. Actualización DDL de tabla categorias_vehiculo
ALTER TABLE categorias_vehiculo
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(40),
    ADD COLUMN IF NOT EXISTS icono VARCHAR(100),
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 2. Actualización DDL de tabla tipos_transmision
ALTER TABLE tipos_transmision
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(20);

-- 3. Actualización DDL de tabla tipos_combustible
ALTER TABLE tipos_combustible
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(20);

-- 4. Actualización DDL de tabla caracteristicas
ALTER TABLE caracteristicas
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(50),
    ADD COLUMN IF NOT EXISTS icono VARCHAR(50),
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 5. Actualización DDL de tabla vehiculos
ALTER TABLE vehiculos
    ADD COLUMN IF NOT EXISTS disponible BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS calificacion NUMERIC(3,2) DEFAULT 5.0 CHECK (calificacion BETWEEN 0 AND 5),
    ADD COLUMN IF NOT EXISTS tarifa_km_ilimitado NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS km_incluidos_dia INTEGER DEFAULT 200,
    ADD COLUMN IF NOT EXISTS tarifa_km_excedente NUMERIC(12,2) DEFAULT 800;

-- 6. Creación de Tabla de Bloqueos de Disponibilidad por Calendario
CREATE TABLE IF NOT EXISTS disponibilidad_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ NOT NULL,
    tipo_bloqueo VARCHAR(30) NOT NULL DEFAULT 'RESERVA' CHECK (tipo_bloqueo IN ('RESERVA', 'MANTENIMIENTO', 'INSPECCION', 'BLOQUEO_MANUAL', 'TRASLADO')),
    reserva_id UUID REFERENCES reservas(id) ON DELETE SET NULL,
    motivo VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_fin > fecha_inicio)
);

-- 7. Creación de Tabla de Reseñas y Comentarios de Vehículo
CREATE TABLE IF NOT EXISTS comentarios_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    autor_nombre VARCHAR(150) NOT NULL,
    calificacion SMALLINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT NOT NULL,
    fecha_comentario DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. Vista Consolidada de Catálogo de Vehículos
CREATE OR REPLACE VIEW catalogo_vehiculos AS
SELECT 
    v.id,
    v.placa,
    v.vin,
    v.modelo,
    m.nombre AS marca,
    c.nombre AS categoria,
    c.codigo AS categoria_codigo,
    t.nombre AS transmision,
    f.nombre AS combustible,
    ev.codigo AS estado_operativo_codigo,
    ev.nombre AS estado_operativo,
    ev.permite_reserva AS permite_reserva_operativa,
    v.disponible AS disponible_reserva,
    s.id AS sede_id,
    s.nombre AS sede_nombre,
    s.direccion AS sede_direccion,
    ciu.nombre AS ciudad_nombre,
    dep.nombre AS departamento_nombre,
    v.anio,
    v.color,
    v.capacidad_pasajeros,
    v.numero_puertas,
    v.capacidad_maletero_litros,
    v.cilindraje,
    v.descripcion,
    v.destacado,
    v.calificacion,
    v.kilometraje,
    v.tarifa_diaria,
    v.tarifa_km_ilimitado,
    v.km_incluidos_dia,
    v.tarifa_km_excedente,
    v.activo,
    v.created_at,
    v.updated_at
FROM vehiculos v
JOIN marcas m ON v.marca_id = m.id
JOIN categorias_vehiculo c ON v.categoria_id = c.id
JOIN tipos_transmision t ON v.transmision_id = t.id
JOIN tipos_combustible f ON v.combustible_id = f.id
JOIN estados_vehiculo ev ON v.estado_id = ev.id
JOIN sedes s ON v.sede_actual_id = s.id
JOIN ciudades ciu ON s.ciudad_id = ciu.id
JOIN departamentos dep ON ciu.departamento_id = dep.id;

-- 9. Creación de Índices de Búsqueda y Filtrado

-- 1. Índices Únicos y Búsqueda por Identificadores
CREATE INDEX IF NOT EXISTS idx_vehiculos_placa ON vehiculos(placa);
CREATE INDEX IF NOT EXISTS idx_vehiculos_vin ON vehiculos(vin);

-- 2. Índices por Relaciones y Filtros Principales
CREATE INDEX IF NOT EXISTS idx_vehiculos_categoria_id ON vehiculos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_vehiculos_sede_actual_id ON vehiculos(sede_actual_id);
CREATE INDEX IF NOT EXISTS idx_vehiculos_marca_id ON vehiculos(marca_id);
CREATE INDEX IF NOT EXISTS idx_vehiculos_estado_id ON vehiculos(estado_id);
CREATE INDEX IF NOT EXISTS idx_vehiculos_transmision_id ON vehiculos(transmision_id);
CREATE INDEX IF NOT EXISTS idx_vehiculos_combustible_id ON vehiculos(combustible_id);

-- 3. Índices de Disponibilidad y Estado Operativo
CREATE INDEX IF NOT EXISTS idx_vehiculos_disponible ON vehiculos(disponible);
CREATE INDEX IF NOT EXISTS idx_vehiculos_activo ON vehiculos(activo);
CREATE INDEX IF NOT EXISTS idx_vehiculos_destacado ON vehiculos(destacado, activo);

-- 4. Índice Compuesto de Alto Rendimiento para Consultas de Catálogo
CREATE INDEX IF NOT EXISTS idx_vehiculos_catalogo_busqueda ON vehiculos(categoria_id, sede_actual_id, estado_id, disponible, activo);

-- 5. Índices para Características, Imágenes y Disponibilidad de Fechas
CREATE INDEX IF NOT EXISTS idx_vehiculo_caracteristicas_veh ON vehiculo_caracteristicas(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_caracteristicas_car ON vehiculo_caracteristicas(caracteristica_id);
CREATE INDEX IF NOT EXISTS idx_imagenes_vehiculo_veh_ord ON imagenes_vehiculo(vehiculo_id, orden);
CREATE INDEX IF NOT EXISTS idx_disponibilidad_vehiculo_rango ON disponibilidad_vehiculo(vehiculo_id, fecha_inicio, fecha_fin);
CREATE INDEX IF NOT EXISTS idx_comentarios_vehiculo_veh_id ON comentarios_vehiculo(vehiculo_id);

-- 10. Inserción de Semillas Iniciales
-- 1. Inserción de Marcas
INSERT INTO marcas (nombre, activo)
VALUES
    ('Toyota', TRUE),
    ('Mazda', TRUE),
    ('Chevrolet', TRUE),
    ('Ford', TRUE),
    ('Renault', TRUE),
    ('Hyundai', TRUE),
    ('Kia', TRUE),
    ('Nissan', TRUE),
    ('Volkswagen', TRUE),
    ('BMW', TRUE),
    ('Mercedes-Benz', TRUE),
    ('Suzuki', TRUE),
    ('Honda', TRUE),
    ('Jeep', TRUE),
    ('Mitsubishi', TRUE)
ON CONFLICT (nombre) DO UPDATE SET activo = EXCLUDED.activo;

-- 2. Inserción de Categorías de Vehículo
INSERT INTO categorias_vehiculo (codigo, nombre, descripcion, tarifa_base_diaria, deposito_garantia, activo)
VALUES
    ('SEDAN', 'Sedan', 'Vehículos cómodos y elegantes de 4 puertas para ciudad y viaje', 85000, 500000, TRUE),
    ('SUV', 'SUV', 'Camionetas espaciosas y versátiles para todo tipo de terreno y familias', 120000, 800000, TRUE),
    ('ECONOMICO', 'Económico', 'Autos compactos de excelente rendimiento de combustible', 65000, 400000, TRUE),
    ('DEPORTIVO', 'Deportivo', 'Vehículos de alta potencia, aceleración y diseño prémium', 220000, 1500000, TRUE),
    ('COMPACTO', 'Compacto', 'Fáciles de parquear y maniobrar en tráfico urbano', 70000, 450000, TRUE),
    ('PICKUP', 'Pickup', 'Camionetas con platón para carga y trabajo pesado', 160000, 1000000, TRUE),
    ('VAN', 'Van', 'Vehículos para transporte de grupos y familias numerosas', 180000, 1200000, TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    codigo = EXCLUDED.codigo,
    descripcion = EXCLUDED.descripcion,
    tarifa_base_diaria = EXCLUDED.tarifa_base_diaria,
    deposito_garantia = EXCLUDED.deposito_garantia,
    activo = EXCLUDED.activo;

-- 3. Inserción de Tipos de Transmisión
INSERT INTO tipos_transmision (codigo, nombre)
VALUES
    ('AUTOMATICA', 'Automática'),
    ('MANUAL', 'Manual'),
    ('SECUENCIAL', 'Secuencial')
ON CONFLICT (nombre) DO UPDATE SET codigo = EXCLUDED.codigo;

-- 4. Inserción de Tipos de Combustible
INSERT INTO tipos_combustible (codigo, nombre)
VALUES
    ('GASOLINA', 'Gasolina'),
    ('DIESEL', 'Diesel'),
    ('HIBRIDO', 'Híbrido'),
    ('ELECTRICO', 'Eléctrico'),
    ('GAS', 'Gas / GLP')
ON CONFLICT (nombre) DO UPDATE SET codigo = EXCLUDED.codigo;

-- 5. Inserción de Estados Operativos de Vehículo
INSERT INTO estados_vehiculo (codigo, nombre, permite_reserva)
VALUES
    ('DISPONIBLE', 'Disponible / Operativo', TRUE),
    ('MANTENIMIENTO', 'En Mantenimiento Preventivo', FALSE),
    ('EN_REPARACION', 'En Reparación de Taller', FALSE),
    ('FUERA_DE_SERVICIO', 'Fuera de Servicio Temporal', FALSE),
    ('RETIRADO', 'Retirado Definitivo de Flota', FALSE)
ON CONFLICT (codigo) DO UPDATE
SET
    nombre = EXCLUDED.nombre,
    permite_reserva = EXCLUDED.permite_reserva;

-- 6. Inserción de Catálogo de Características y Equipamiento
INSERT INTO caracteristicas (codigo, nombre, icono, grupo, descripcion, activo)
VALUES
    ('AIRE_ACONDICIONADO', 'Aire acondicionado', 'FaSnowflake', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('VIDRIOS_ELECTRICOS', 'Vidrios eléctricos', 'FaWindowMaximize', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('CIERRE_CENTRALIZADO', 'Cierre centralizado', 'FaLock', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('TECHO_PANORAMICO', 'Techo panorámico', 'FaSun', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('MODO_DEPORTIVO', 'Modo deportivo', 'FaTachometerAlt', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('FRENOS_ALTO_RENDIMIENTO', 'Frenos de alto rendimiento', 'FaStopCircle', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('TRACCION_4X4', 'Tracción 4x4', 'FaMountain', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('TERCERA_FILA_ASIENTOS', 'Tercera fila de asientos', 'FaUsers', 'CARACTERISTICA', 'Equipamiento oficial del catálogo', TRUE),
    ('BLUETOOTH', 'Bluetooth', 'FaBluetoothB', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('PUERTO_USB', 'Puerto USB', 'FaPlug', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('PANTALLA_TACTIL', 'Pantalla táctil', 'FaMobileAlt', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('CAMARA_REVERSA', 'Cámara de reversa', 'FaCamera', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('SENSORES_PARQUEO', 'Sensores de parqueo', 'FaCarSide', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('SENSORES_PUNTO_CIEGO', 'Sensores de punto ciego', 'FaEye', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('SISTEMA_SONIDO_PREMIUM', 'Sistema de sonido premium', 'FaVolumeUp', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE),
    ('CARGADOR_INALAMBRICO', 'Cargador inalámbrico', 'FaChargingStation', 'EQUIPAMIENTO_TECNOLOGICO', 'Equipamiento oficial del catálogo', TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    codigo = EXCLUDED.codigo,
    icono = EXCLUDED.icono,
    grupo = EXCLUDED.grupo,
    activo = EXCLUDED.activo;

-- 7. Inserción de Vehículos de la Flota

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'ABC-123',
    '935ABCD1234567890',
    (SELECT id FROM marcas WHERE nombre = 'Toyota'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'Sedan'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Gasolina'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alamo Bogotá - Aeropuerto'),
    'Toyota Corolla 2024',
    2024,
    'Blanco Perla',
    5,
    4,
    470,
    '1.8L',
    'Sedán confiable y espacioso, ideal para viajes largos o uso diario en la ciudad. Ofrece una excelente relación de consumo de combustible y un maletero generoso para todo tu equipaje. Máxima comodidad.',
    TRUE,
    4.8,
    15000,
    85000,
    105000,
    200,
    800,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Sensores de parqueo'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'ABC-123' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/a2cb0b378c25efdb1e116246f84149744c2f4081.jpg', TRUE, 1
FROM vehiculos WHERE placa = 'ABC-123'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/1c6e90229d22ae38444b4c27a5ecedbc3aaa7739.jpg', FALSE, 2
FROM vehiculos WHERE placa = 'ABC-123'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/5c55d73935760e36ac2c84a6f676e75136c75d1f.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'ABC-123'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Carlos M.', 5, 'Excelente vehículo, muy cómodo y puntual en la entrega.', '2026-04-10'::date
FROM vehiculos WHERE placa = 'ABC-123'
ON CONFLICT DO NOTHING;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Laura P.', 4, 'Buen servicio, el carro en perfectas condiciones.', '2026-03-22'::date
FROM vehiculos WHERE placa = 'ABC-123'
ON CONFLICT DO NOTHING;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Andrés R.', 5, 'Lo recomiendo totalmente, volveré a alquilar.', '2026-03-05'::date
FROM vehiculos WHERE placa = 'ABC-123'
ON CONFLICT DO NOTHING;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'DEF-456',
    '935DEF45678901234',
    (SELECT id FROM marcas WHERE nombre = 'Mazda'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'SUV'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Gasolina'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alamo Medellín Poblado'),
    'Mazda CX-5 2024',
    2024,
    'Soul Red Crystal',
    5,
    5,
    442,
    '2.5L',
    'SUV premium que destaca por su gran presencia y comodidad para toda la familia. Incluye techo panorámico, acabados de lujo y tecnología de seguridad avanzada para brindarte tranquilidad. Excelente diseño.',
    TRUE,
    4.9,
    15000,
    145000,
    175000,
    250,
    1000,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Techo panorámico'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'DEF-456' AND c.nombre = 'Sensores de punto ciego'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/5acb88622cc00284455f7d6c6e19fd2f5b11a6cd.jpg', TRUE, 1
FROM vehiculos WHERE placa = 'DEF-456'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/3660959c1dc9ad6069d89d42723db9cda29afeba.jpg', FALSE, 2
FROM vehiculos WHERE placa = 'DEF-456'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/ec7412fd3f8148ee85aeb9d7c9a05577be7409d6.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'DEF-456'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Mariana Gómez', 5, 'Excelente SUV, superó mis expectativas.', '2026-05-12'::date
FROM vehiculos WHERE placa = 'DEF-456'
ON CONFLICT DO NOTHING;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Daniel O.', 5, 'Muy cómoda para el viaje en familia, excelente consumo.', '2026-06-22'::date
FROM vehiculos WHERE placa = 'DEF-456'
ON CONFLICT DO NOTHING;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'GHI-789',
    '935GHI78901234567',
    (SELECT id FROM marcas WHERE nombre = 'Chevrolet'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'Económico'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Manual'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Gasolina'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'National Downtown Barranquilla'),
    'Chevrolet Spark 2023',
    2023,
    'Rojo Passion',
    4,
    4,
    170,
    '1.0L',
    'Vehículo compacto, ágil y muy económico, perfecto para moverte rápidamente por la ciudad. Te permite estacionar sin complicaciones y ofrece un rendimiento de combustible insuperable para el día a día. Gran elección.',
    TRUE,
    4.5,
    15000,
    60000,
    75000,
    150,
    600,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'GHI-789' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'GHI-789' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'GHI-789' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'GHI-789' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'GHI-789' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.fXE8mmnIQyu_3aOZ3jDciAHaE0?w=277&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', TRUE, 1
FROM vehiculos WHERE placa = 'GHI-789'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.Ta7fayfrmFJd3HPo8xojKAHaEJ?w=321&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', FALSE, 2
FROM vehiculos WHERE placa = 'GHI-789'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.M8Xr6C7QAbptaShiYv_SigHaEi?w=259&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', FALSE, 3
FROM vehiculos WHERE placa = 'GHI-789'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'JKL-012',
    '935JKL01234567890',
    (SELECT id FROM marcas WHERE nombre = 'Ford'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'Deportivo'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Gasolina'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alamo Cartagena - Aeropuerto'),
    'Ford Mustang GT 2023',
    2023,
    'Race Red',
    4,
    2,
    382,
    '5.0L V8',
    'Ícono deportivo inconfundible equipado con un potente motor V8 de alto rendimiento. Pensado exclusivamente para quienes buscan sentir la adrenalina pura y vivir una experiencia de conducción verdaderamente única y emocionante.',
    FALSE,
    4.7,
    15000,
    220000,
    260000,
    300,
    1500,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Modo deportivo'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Frenos de alto rendimiento'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'JKL-012' AND c.nombre = 'Sistema de sonido premium'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.1fmggTD9brrhHIbn4PxbFQHaEK?w=294&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', TRUE, 1
FROM vehiculos WHERE placa = 'JKL-012'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.YtLn_MV5ghgGtbCAOjl6zwHaE6?w=250&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', FALSE, 2
FROM vehiculos WHERE placa = 'JKL-012'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/R.2312c5cbb5b968f100d34bdbde5c576a?rik=Mw4jE71kRKyhuA&riu=http%3a%2f%2fimages.gtcarlot.com%2fpictures%2f145962677.jpg&ehk=fs3qI14Aid1CfPQQ%2f23zMMfkFuVyphuDrrOvFIsJMY8%3d&risl=&pid=ImgRaw&r=0', FALSE, 3
FROM vehiculos WHERE placa = 'JKL-012'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Sebastián T.', 5, 'Una locura de carro, corre muchísimo y está impecable.', '2026-01-10'::date
FROM vehiculos WHERE placa = 'JKL-012'
ON CONFLICT DO NOTHING;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'MNO-345',
    '935MNO34567890123',
    (SELECT id FROM marcas WHERE nombre = 'Toyota'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'SUV'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Diesel'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alamo Cali - Aeropuerto'),
    'Toyota Prado 2024',
    2024,
    'Super White',
    8,
    5,
    390,
    '2.8L Diesel',
    'Imponente SUV de 8 pasajeros equipada con tracción 4x4. Es la opción ideal para realizar viajes familiares largos con total confort o para enfrentarse a terrenos exigentes sin ningún problema. Capacidad extrema.',
    FALSE,
    4.6,
    15000,
    180000,
    215000,
    300,
    1200,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Tracción 4x4'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Tercera fila de asientos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'MNO-345' AND c.nombre = 'Sensores de parqueo'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/4d34066b6e9e1a29c93d7d0edeb2f415058411d3.jpg', TRUE, 1
FROM vehiculos WHERE placa = 'MNO-345'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/64be097eae7f8698be22c3646647d73c234e60a0.jpg', FALSE, 2
FROM vehiculos WHERE placa = 'MNO-345'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/ef353e43a859b12a67c8bd45cb5f5265beddef2a.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'MNO-345'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Julio R.', 4, 'Perfecta para ir al campo, muy fuerte.', '2026-02-14'::date
FROM vehiculos WHERE placa = 'MNO-345'
ON CONFLICT DO NOTHING;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Ana Maria', 5, 'Espacio de sobra para toda la familia. La volveré a alquilar.', '2026-03-01'::date
FROM vehiculos WHERE placa = 'MNO-345'
ON CONFLICT DO NOTHING;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'PQR-678',
    '935PQR67890123456',
    (SELECT id FROM marcas WHERE nombre = 'Renault'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'Económico'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Manual'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Gasolina'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alquiler Neiva - Centro'),
    'Renault Sandero 2023',
    2023,
    'Gris Highland',
    5,
    5,
    320,
    '1.6L',
    'Vehículo compacto ideal para la ciudad, con un habitáculo súper cómodo para 5 pasajeros. Cuenta con un excelente rendimiento de combustible que cuida tu bolsillo durante todos tus desplazamientos diarios. Gran vehículo.',
    FALSE,
    4.3,
    15000,
    55000,
    68000,
    150,
    550,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'PQR-678' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.M8Xr6C7QAbptaShiYv_SigHaEi?w=259&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', TRUE, 1
FROM vehiculos WHERE placa = 'PQR-678'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.51EBaowC6BNblc7CVjxDMQHaFL?w=258&h=181&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', FALSE, 2
FROM vehiculos WHERE placa = 'PQR-678'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/5c55d73935760e36ac2c84a6f676e75136c75d1f.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'PQR-678'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Camila R.', 5, 'Muy cómodo para viajes cortos, sin problemas mecánicos y el proceso de entrega fue rápido.', '2026-06-14'::date
FROM vehiculos WHERE placa = 'PQR-678'
ON CONFLICT DO NOTHING;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Juan P.', 4, 'Buen carro y buen precio, aunque el aire tardó un poco en enfriar el primer día.', '2026-05-30'::date
FROM vehiculos WHERE placa = 'PQR-678'
ON CONFLICT DO NOTHING;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'STU-901',
    '935STU90123456789',
    (SELECT id FROM marcas WHERE nombre = 'Hyundai'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'SUV'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Híbrido'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alamo Bucaramanga - Aeropuerto'),
    'Hyundai Tucson 2024',
    2024,
    'Phantom Black',
    5,
    5,
    513,
    '1.6L Híbrido',
    'Sofisticada SUV híbrida, reconocida por ser muy eficiente y silenciosa. Cuenta con un amplio espacio de carga y lo último en tecnología de asistencia al conductor para mayor seguridad. Tecnología limpia.',
    FALSE,
    4.8,
    15000,
    160000,
    192000,
    250,
    1100,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Techo panorámico'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'STU-901' AND c.nombre = 'Cargador inalámbrico'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/c86e9f8dd37048853c7c2fce700fb4bb5b1e062c.jpg', TRUE, 1
FROM vehiculos WHERE placa = 'STU-901'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/8631ecb31093479ab34a56263b478b44fb2d74f6.jpg', FALSE, 2
FROM vehiculos WHERE placa = 'STU-901'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/aa041a9462ecf25c4c543ea284f7af255338df95.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'STU-901'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO comentarios_vehiculo (vehiculo_id, autor_nombre, calificacion, comentario, fecha_comentario)
SELECT id, 'Luis C.', 5, 'Muy económica por ser híbrida. Totalmente recomendada.', '2026-07-02'::date
FROM vehiculos WHERE placa = 'STU-901'
ON CONFLICT DO NOTHING;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'VWX-234',
    '935VWX23456789012',
    (SELECT id FROM marcas WHERE nombre = 'Kia'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'Sedan'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Gasolina'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Alamo Pereira - Aeropuerto'),
    'Kia Cerato 2024',
    2024,
    'Snow White Pearl',
    5,
    4,
    502,
    '2.0L',
    'Elegante sedán moderno y confortable, diseñado con un gran maletero y acabados de altísima calidad. Es el compañero perfecto tanto para trayectos diarios como para viajes importantes de negocios. Confort garantizado.',
    FALSE,
    4.4,
    15000,
    95000,
    115000,
    200,
    900,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'VWX-234' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/7718dbfc25ce3e387cb976f4ded742dc8d8c7582.jpg', TRUE, 1
FROM vehiculos WHERE placa = 'VWX-234'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/1e686f124bd42a21481a43969615adc261e39251.jpg', FALSE, 2
FROM vehiculos WHERE placa = 'VWX-234'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/de7fef41a3ee96557b1600b7e91494dd78a5e7b1.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'VWX-234'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    numero_puertas, capacidad_maletero_litros, cilindraje, descripcion,
    destacado, calificacion, kilometraje, tarifa_diaria, tarifa_km_ilimitado,
    km_incluidos_dia, tarifa_km_excedente, disponible, activo
)
VALUES (
    'YZA-567',
    '935YZA56789012345',
    (SELECT id FROM marcas WHERE nombre = 'Nissan'),
    (SELECT id FROM categorias_vehiculo WHERE nombre = 'SUV'),
    (SELECT id FROM tipos_transmision WHERE nombre = 'Automática'),
    (SELECT id FROM tipos_combustible WHERE nombre = 'Híbrido'),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE'),
    (SELECT id FROM sedes WHERE nombre = 'Localiza Cúcuta Aeropuerto Camilo Daza'),
    'Nissan Qashqai 2024',
    2024,
    'Magnetic Blue',
    5,
    5,
    504,
    '1.3L Turbo MHEV',
    'SUV híbrida premium que ofrece una gran eficiencia de combustible. Su interior destaca por un hermoso techo panorámico y un espacio muy generoso tanto para pasajeros como para su equipaje. Viajes inolvidables.',
    TRUE,
    4.9,
    15000,
    140000,
    170000,
    250,
    1000,
    TRUE,
    TRUE
)
ON CONFLICT (placa) DO UPDATE
SET
    vin = EXCLUDED.vin,
    marca_id = EXCLUDED.marca_id,
    categoria_id = EXCLUDED.categoria_id,
    transmision_id = EXCLUDED.transmision_id,
    combustible_id = EXCLUDED.combustible_id,
    estado_id = EXCLUDED.estado_id,
    sede_actual_id = EXCLUDED.sede_actual_id,
    modelo = EXCLUDED.modelo,
    anio = EXCLUDED.anio,
    color = EXCLUDED.color,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    numero_puertas = EXCLUDED.numero_puertas,
    capacidad_maletero_litros = EXCLUDED.capacidad_maletero_litros,
    cilindraje = EXCLUDED.cilindraje,
    descripcion = EXCLUDED.descripcion,
    destacado = EXCLUDED.destacado,
    calificacion = EXCLUDED.calificacion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_ilimitado = EXCLUDED.tarifa_km_ilimitado,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    disponible = EXCLUDED.disponible,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Aire acondicionado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Vidrios eléctricos'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Cierre centralizado'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Techo panorámico'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Bluetooth'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Puerto USB'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Pantalla táctil'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Cámara de reversa'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO vehiculo_caracteristicas (vehiculo_id, caracteristica_id)
SELECT v.id, c.id
FROM vehiculos v, caracteristicas c
WHERE v.placa = 'YZA-567' AND c.nombre = 'Sensores de punto ciego'
ON CONFLICT (vehiculo_id, caracteristica_id) DO NOTHING;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/5acb88622cc00284455f7d6c6e19fd2f5b11a6cd.jpg', TRUE, 1
FROM vehiculos WHERE placa = 'YZA-567'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://th.bing.com/th/id/OIP.fXE8mmnIQyu_3aOZ3jDciAHaE0?w=277&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3', FALSE, 2
FROM vehiculos WHERE placa = 'YZA-567'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;

INSERT INTO imagenes_vehiculo (vehiculo_id, url, es_principal, orden)
SELECT id, 'https://pplx-res.cloudinary.com/image/upload/pplx_search_images/8631ecb31093479ab34a56263b478b44fb2d74f6.jpg', FALSE, 3
FROM vehiculos WHERE placa = 'YZA-567'
ON CONFLICT (vehiculo_id, orden) DO UPDATE SET url = EXCLUDED.url, es_principal = EXCLUDED.es_principal;
