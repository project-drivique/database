-- ==============================================================================
-- Flyway Migration: V4__ciudades_y_sucursales.sql
-- Historia: HU-BD-04 - Persistir Ciudades y Sucursales
-- ==============================================================================

-- 1. Actualización DDL de tabla departamentos
ALTER TABLE departamentos
    ADD COLUMN IF NOT EXISTS codigo_iso CHAR(6),
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 2. Actualización DDL de tabla ciudades
ALTER TABLE ciudades
    ADD COLUMN IF NOT EXISTS codigo_dane VARCHAR(10),
    ADD COLUMN IF NOT EXISTS tiene_aeropuerto BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS tiene_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS pico_y_placa_info JSONB,
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 3. Actualización DDL de tabla sedes (Sucursales)
ALTER TABLE sedes
    ADD COLUMN IF NOT EXISTS email_contacto VARCHAR(254),
    ADD COLUMN IF NOT EXISTS horario_atencion VARCHAR(150) DEFAULT 'Lunes a Domingo 07:00 - 20:00',
    ADD COLUMN IF NOT EXISTS encargado_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS es_aeropuerto BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS es_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS permite_pago_efectivo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 4. Creación de Índices de Búsqueda y Filtrado
CREATE INDEX IF NOT EXISTS idx_ciudades_nombre ON ciudades(nombre);
CREATE INDEX IF NOT EXISTS idx_ciudades_activo ON ciudades(activo);
CREATE INDEX IF NOT EXISTS idx_ciudades_departamento_id ON ciudades(departamento_id);
CREATE INDEX IF NOT EXISTS idx_ciudades_dept_activo ON ciudades(departamento_id, activo);

CREATE INDEX IF NOT EXISTS idx_sedes_nombre ON sedes(nombre);
CREATE INDEX IF NOT EXISTS idx_sedes_ciudad_id ON sedes(ciudad_id);
CREATE INDEX IF NOT EXISTS idx_sedes_activo ON sedes(activo);
CREATE INDEX IF NOT EXISTS idx_sedes_ciudad_activo ON sedes(ciudad_id, activo);
CREATE INDEX IF NOT EXISTS idx_sedes_permite_pago_efectivo ON sedes(permite_pago_efectivo);
CREATE INDEX IF NOT EXISTS idx_sedes_es_aeropuerto ON sedes(es_aeropuerto);
CREATE INDEX IF NOT EXISTS idx_sedes_es_terminal ON sedes(es_terminal);

-- 5. Vista de Compatibilidad: sucursales
CREATE OR REPLACE VIEW sucursales AS
SELECT 
    s.id,
    s.nombre,
    s.direccion,
    s.ciudad_id,
    c.nombre AS ciudad_nombre,
    d.nombre AS departamento_nombre,
    s.telefono,
    s.email_contacto,
    s.horario_atencion,
    s.encargado_id,
    s.pais,
    s.es_aeropuerto,
    s.es_terminal,
    s.permite_pago_efectivo,
    s.activo,
    s.created_at,
    s.updated_at
FROM sedes s
JOIN ciudades c ON s.ciudad_id = c.id
JOIN departamentos d ON c.departamento_id = d.id;

-- 6. Inserción de Semillas Iniciales


-- 1. Departamentos de Colombia
INSERT INTO departamentos (nombre, codigo_iso, activo)
VALUES
    ('Cundinamarca', 'CO-CUN', TRUE),
    ('Antioquia', 'CO-ANT', TRUE),
    ('Valle del Cauca', 'CO-VAC', TRUE),
    ('Atlántico', 'CO-ATL', TRUE),
    ('Bolívar', 'CO-BOL', TRUE),
    ('Santander', 'CO-SAN', TRUE),
    ('Risaralda', 'CO-RIS', TRUE),
    ('Norte de Santander', 'CO-NSA', TRUE),
    ('Magdalena', 'CO-MAG', TRUE),
    ('Caldas', 'CO-CAL', TRUE),
    ('Tolima', 'CO-TOL', TRUE),
    ('Nariño', 'CO-NAR', TRUE),
    ('Meta', 'CO-MET', TRUE),
    ('Córdoba', 'CO-COR', TRUE),
    ('Cesar', 'CO-CES', TRUE),
    ('Quindío', 'CO-QUI', TRUE),
    ('Huila', 'CO-HUI', TRUE),
    ('Cauca', 'CO-CAU', TRUE),
    ('Sucre', 'CO-SUC', TRUE),
    ('Boyacá', 'CO-BOY', TRUE),
    ('La Guajira', 'CO-LAG', TRUE),
    ('Chocó', 'CO-CHO', TRUE),
    ('Caquetá', 'CO-CAQ', TRUE),
    ('Casanare', 'CO-CAS', TRUE),
    ('San Andrés y Providencia', 'CO-SAP', TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    codigo_iso = EXCLUDED.codigo_iso,
    activo = EXCLUDED.activo;

-- 2. Ciudades Principales
INSERT INTO ciudades (
    departamento_id, nombre, codigo_dane, tiene_aeropuerto, tiene_terminal, pico_y_placa_info, activo
)
VALUES
    ((SELECT id FROM departamentos WHERE nombre = 'Cundinamarca'), 'Bogotá', '11001', TRUE, TRUE, '{"aplica":true,"horario":"6:00 AM - 9:00 PM","dias":"Lunes a Viernes","esquema":"par-impar","notaLink":"https://www.sdm.gov.co/gestion-del-transito/pico-y-placa"}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Antioquia'), 'Medellín', '05001', TRUE, TRUE, '{"aplica":true,"horario":"5:00 AM - 8:00 PM","dias":"Lunes a Viernes","esquema":"rotacion-semestral","notaLink":"https://www.medellin.gov.co/es/pico-y-placa/"}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Valle del Cauca'), 'Cali', '76001', TRUE, TRUE, '{"aplica":true,"horario":"6:00 AM - 8:00 PM","dias":"Lunes a Viernes","esquema":"rotacion-semestral","notaLink":"https://www.cali.gov.co/movilidad/publicaciones/180234/pico-y-placa/"}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Atlántico'), 'Barranquilla', '08001', TRUE, TRUE, '{"aplica":true,"horario":"Variable","dias":"Lunes a Viernes","esquema":"rotacion-taxis-y-particulares","notaLink":"https://www.barranquilla.gov.co/transito"}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Bolívar'), 'Cartagena', '13001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Santander'), 'Bucaramanga', '68001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Risaralda'), 'Pereira', '66001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Norte de Santander'), 'Cúcuta', '54001', TRUE, FALSE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Magdalena'), 'Santa Marta', '47001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Caldas'), 'Manizales', '17001', FALSE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Tolima'), 'Ibagué', '73001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Nariño'), 'Pasto', '52001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Meta'), 'Villavicencio', '50001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Córdoba'), 'Montería', '23001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Cesar'), 'Valledupar', '20001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Quindío'), 'Armenia', '63001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Huila'), 'Neiva', '41001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Cauca'), 'Popayán', '19001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Sucre'), 'Sincelejo', '70001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Boyacá'), 'Tunja', '15001', FALSE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'La Guajira'), 'Riohacha', '44001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Chocó'), 'Quibdó', '27001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Caquetá'), 'Florencia', '18001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'Casanare'), 'Yopal', '85001', TRUE, TRUE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE),
    ((SELECT id FROM departamentos WHERE nombre = 'San Andrés y Providencia'), 'San Andrés', '88001', TRUE, FALSE, '{"aplica":false,"horario":"Sin restricción","dias":"N/A","esquema":"ninguno","notaLink":""}'::jsonb, TRUE)
ON CONFLICT (departamento_id, nombre) DO UPDATE
SET
    codigo_dane = EXCLUDED.codigo_dane,
    tiene_aeropuerto = EXCLUDED.tiene_aeropuerto,
    tiene_terminal = EXCLUDED.tiene_terminal,
    pico_y_placa_info = EXCLUDED.pico_y_placa_info,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;

-- 3. Sedes y Sucursales
INSERT INTO sedes (
    nombre, direccion, ciudad_id, pais, telefono, email_contacto,
    horario_atencion, es_aeropuerto, es_terminal, permite_pago_efectivo, activo
)
VALUES
    ('Alamo Bogotá - Aeropuerto', 'El Dorado International Airport (BOG), Terminal de Carga, Fontibón', (SELECT id FROM ciudades WHERE nombre = 'Bogotá'), 'CO', '+57 310 101 2001', 'enc01@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, TRUE, TRUE, TRUE),
    ('Alamo Bogotá - Calle 80', 'Av. Calle 80 # 45-20, Barrio Polo Club', (SELECT id FROM ciudades WHERE nombre = 'Bogotá'), 'CO', '+57 310 102 2002', 'enc02@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Bogota El Dorado Intl. Airport', 'Aeropuerto El Dorado (BOG), Puerta 4', (SELECT id FROM ciudades WHERE nombre = 'Bogotá'), 'CO', '+57 310 103 2003', 'enc03@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('National Medellín Centro', 'Cra. 48 # 12-15, La Candelaria', (SELECT id FROM ciudades WHERE nombre = 'Medellín'), 'CO', '+57 310 104 2004', 'enc04@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Medellin Rionegro Jose Maria Cordova Intl. Airport', 'Aeropuerto MDE, Rionegro, Antioquia', (SELECT id FROM ciudades WHERE nombre = 'Medellín'), 'CO', '+57 310 105 2005', 'enc05@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alamo Medellín Poblado', 'Cra. 43A # 14-70, El Poblado', (SELECT id FROM ciudades WHERE nombre = 'Medellín'), 'CO', '+57 310 106 2006', 'enc06@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alamo Cali - Aeropuerto', 'Aeropuerto Alfonso Bonilla Aragón (CLO), Palmira', (SELECT id FROM ciudades WHERE nombre = 'Cali'), 'CO', '+57 310 107 2007', 'enc07@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alamo Cali - Ciudad', 'Av. 6N # 25N-45, Granada', (SELECT id FROM ciudades WHERE nombre = 'Cali'), 'CO', '+57 310 108 2008', 'enc08@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Cali Centro', 'Calle 12 # 3-15, Centro', (SELECT id FROM ciudades WHERE nombre = 'Cali'), 'CO', '+57 310 109 2009', 'enc09@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Cali International Airport', 'Aeropuerto CLO, Palmira', (SELECT id FROM ciudades WHERE nombre = 'Cali'), 'CO', '+57 310 110 2010', 'enc10@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alamo Barranquilla - Aeropuerto', 'Aeropuerto Ernesto Cortissoz (BAQ), Soledad', (SELECT id FROM ciudades WHERE nombre = 'Barranquilla'), 'CO', '+57 310 111 2011', 'enc11@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alamo Barranquilla - Ciudad', 'Calle 98 # 45-50, Alto Prado', (SELECT id FROM ciudades WHERE nombre = 'Barranquilla'), 'CO', '+57 310 112 2012', 'enc12@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Barranquilla Airport', 'Aeropuerto BAQ, Soledad', (SELECT id FROM ciudades WHERE nombre = 'Barranquilla'), 'CO', '+57 310 113 2013', 'enc13@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('National Downtown Barranquilla', 'Calle 72 # 40-30, Centro', (SELECT id FROM ciudades WHERE nombre = 'Barranquilla'), 'CO', '+57 310 114 2014', 'enc14@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alamo Cartagena - Aeropuerto', 'Aeropuerto Rafael Núñez (CTG)', (SELECT id FROM ciudades WHERE nombre = 'Cartagena'), 'CO', '+57 310 115 2015', 'enc15@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('National Cartagena International Airport', 'Aeropuerto CTG', (SELECT id FROM ciudades WHERE nombre = 'Cartagena'), 'CO', '+57 310 116 2016', 'enc16@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alamo Cartagena Centro', 'Av. San Martín # 28-59, Bocagrande', (SELECT id FROM ciudades WHERE nombre = 'Cartagena'), 'CO', '+57 310 117 2017', 'enc17@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alamo Bucaramanga - Aeropuerto', 'Aeropuerto Palo Negro (BGA), Lebrija', (SELECT id FROM ciudades WHERE nombre = 'Bucaramanga'), 'CO', '+57 310 118 2018', 'enc18@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('National Bucaramanga Airport', 'Aeropuerto BGA, Lebrija', (SELECT id FROM ciudades WHERE nombre = 'Bucaramanga'), 'CO', '+57 310 119 2019', 'enc19@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alamo Pereira - Aeropuerto', 'Aeropuerto Matecaña (PEI)', (SELECT id FROM ciudades WHERE nombre = 'Pereira'), 'CO', '+57 310 120 2020', 'enc20@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('National Pereira Intl Airport', 'Aeropuerto PEI', (SELECT id FROM ciudades WHERE nombre = 'Pereira'), 'CO', '+57 310 121 2021', 'enc21@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Localiza Cúcuta Aeropuerto Camilo Daza', 'Aeropuerto CUC', (SELECT id FROM ciudades WHERE nombre = 'Cúcuta'), 'CO', '+57 310 122 2022', 'enc22@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Localiza Cúcuta Centro', 'Av. 4 Este # 12-30, Centro', (SELECT id FROM ciudades WHERE nombre = 'Cúcuta'), 'CO', '+57 310 123 2023', 'enc23@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Santa Marta Airport', 'Aeropuerto Simón Bolívar (SMR)', (SELECT id FROM ciudades WHERE nombre = 'Santa Marta'), 'CO', '+57 310 124 2024', 'enc24@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('National Santa Marta Rodadero', 'Cra. 1 # 12-58, El Rodadero', (SELECT id FROM ciudades WHERE nombre = 'Santa Marta'), 'CO', '+57 310 125 2025', 'enc25@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('National Santa Marta Centro', 'Calle 18 # 3-15, Centro', (SELECT id FROM ciudades WHERE nombre = 'Santa Marta'), 'CO', '+57 310 126 2026', 'enc26@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Localiza Manizales Terminal', 'Cra. 43 # 65-10', (SELECT id FROM ciudades WHERE nombre = 'Manizales'), 'CO', '+57 310 127 2027', 'enc27@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, TRUE, TRUE, TRUE),
    ('Localiza Manizales Aeropuerto La Nubia', 'Aeropuerto MZL', (SELECT id FROM ciudades WHERE nombre = 'Manizales'), 'CO', '+57 310 128 2028', 'enc28@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Ibagué - Centro', 'Cra. 5 # 11-20, Centro', (SELECT id FROM ciudades WHERE nombre = 'Ibagué'), 'CO', '+57 310 129 2029', 'enc29@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Ibagué - Aeropuerto Perales', 'Aeropuerto IBE', (SELECT id FROM ciudades WHERE nombre = 'Ibagué'), 'CO', '+57 310 130 2030', 'enc30@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Pasto - Centro', 'Calle 18 # 24-33, Centro', (SELECT id FROM ciudades WHERE nombre = 'Pasto'), 'CO', '+57 310 131 2031', 'enc31@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Pasto - Aeropuerto Antonio Nariño', 'Aeropuerto PSO', (SELECT id FROM ciudades WHERE nombre = 'Pasto'), 'CO', '+57 310 132 2032', 'enc32@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Villavicencio - Centro', 'Calle 34 # 35-12, Centro', (SELECT id FROM ciudades WHERE nombre = 'Villavicencio'), 'CO', '+57 310 133 2033', 'enc33@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Villavicencio - Aeropuerto Vanguardia', 'Aeropuerto VVC', (SELECT id FROM ciudades WHERE nombre = 'Villavicencio'), 'CO', '+57 310 134 2034', 'enc34@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Montería - Centro', 'Cra. 4 # 32-10, Centro', (SELECT id FROM ciudades WHERE nombre = 'Montería'), 'CO', '+57 310 135 2035', 'enc35@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Montería - Aeropuerto Los Garzones', 'Aeropuerto MTR', (SELECT id FROM ciudades WHERE nombre = 'Montería'), 'CO', '+57 310 136 2036', 'enc36@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Valledupar - Centro', 'Calle 16 # 12-45, Centro', (SELECT id FROM ciudades WHERE nombre = 'Valledupar'), 'CO', '+57 310 137 2037', 'enc37@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Valledupar - Aeropuerto Alfonso López', 'Aeropuerto VUP', (SELECT id FROM ciudades WHERE nombre = 'Valledupar'), 'CO', '+57 310 138 2038', 'enc38@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Armenia - Centro', 'Cra. 14 # 13-20, Centro', (SELECT id FROM ciudades WHERE nombre = 'Armenia'), 'CO', '+57 310 139 2039', 'enc39@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Armenia - Aeropuerto El Edén', 'Aeropuerto AXM', (SELECT id FROM ciudades WHERE nombre = 'Armenia'), 'CO', '+57 310 140 2040', 'enc40@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Neiva - Centro', 'Calle 9 # 8-25, Centro', (SELECT id FROM ciudades WHERE nombre = 'Neiva'), 'CO', '+57 310 141 2041', 'enc41@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Neiva - Aeropuerto Benito Salas', 'Aeropuerto NVA', (SELECT id FROM ciudades WHERE nombre = 'Neiva'), 'CO', '+57 310 142 2042', 'enc42@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Popayán - Centro', 'Calle 5 # 9-30, Centro', (SELECT id FROM ciudades WHERE nombre = 'Popayán'), 'CO', '+57 310 143 2043', 'enc43@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Popayán - Aeropuerto Guillermo León Valencia', 'Aeropuerto PPN', (SELECT id FROM ciudades WHERE nombre = 'Popayán'), 'CO', '+57 310 144 2044', 'enc44@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Sincelejo - Centro', 'Cra. 22 # 18-10, Centro', (SELECT id FROM ciudades WHERE nombre = 'Sincelejo'), 'CO', '+57 310 145 2045', 'enc45@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Sincelejo - Aeropuerto Las Brujas', 'Aeropuerto CZU, Corozal', (SELECT id FROM ciudades WHERE nombre = 'Sincelejo'), 'CO', '+57 310 146 2046', 'enc46@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Tunja - Terminal', 'Av. Oriental # 45-20', (SELECT id FROM ciudades WHERE nombre = 'Tunja'), 'CO', '+57 310 147 2047', 'enc47@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, TRUE, TRUE, TRUE),
    ('Alquiler Riohacha - Centro', 'Calle 10 # 7-15, Centro', (SELECT id FROM ciudades WHERE nombre = 'Riohacha'), 'CO', '+57 310 148 2048', 'enc48@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Riohacha - Aeropuerto Almirante Padilla', 'Aeropuerto RCH', (SELECT id FROM ciudades WHERE nombre = 'Riohacha'), 'CO', '+57 310 149 2049', 'enc49@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Quibdó - Centro', 'Calle 21 # 5-30, Centro', (SELECT id FROM ciudades WHERE nombre = 'Quibdó'), 'CO', '+57 310 150 2050', 'enc50@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Quibdó - Aeropuerto El Caraño', 'Aeropuerto UIB', (SELECT id FROM ciudades WHERE nombre = 'Quibdó'), 'CO', '+57 310 151 2051', 'enc51@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Florencia - Centro', 'Cra. 9 # 14-25, Centro', (SELECT id FROM ciudades WHERE nombre = 'Florencia'), 'CO', '+57 310 152 2052', 'enc52@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Florencia - Aeropuerto Gustavo Artunduaga', 'Aeropuerto FLA', (SELECT id FROM ciudades WHERE nombre = 'Florencia'), 'CO', '+57 310 153 2053', 'enc53@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler Yopal - Centro', 'Calle 12 # 11-40, Centro', (SELECT id FROM ciudades WHERE nombre = 'Yopal'), 'CO', '+57 310 154 2054', 'enc54@drivique.com', 'Lunes a Domingo 07:00 - 20:00', FALSE, FALSE, TRUE, TRUE),
    ('Alquiler Yopal - Aeropuerto El Alcaraván', 'Aeropuerto EYP', (SELECT id FROM ciudades WHERE nombre = 'Yopal'), 'CO', '+57 310 155 2055', 'enc55@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE),
    ('Alquiler San Andrés - Aeropuerto', 'Aeropuerto Gustavo Rojas Pinilla (ADZ)', (SELECT id FROM ciudades WHERE nombre = 'San Andrés'), 'CO', '+57 310 156 2056', 'enc56@drivique.com', 'Lunes a Domingo 24 Horas', TRUE, FALSE, TRUE, TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    direccion = EXCLUDED.direccion,
    ciudad_id = EXCLUDED.ciudad_id,
    telefono = EXCLUDED.telefono,
    email_contacto = EXCLUDED.email_contacto,
    horario_atencion = EXCLUDED.horario_atencion,
    es_aeropuerto = EXCLUDED.es_aeropuerto,
    es_terminal = EXCLUDED.es_terminal,
    permite_pago_efectivo = EXCLUDED.permite_pago_efectivo,
    activo = EXCLUDED.activo,
    updated_at = CURRENT_TIMESTAMP;
