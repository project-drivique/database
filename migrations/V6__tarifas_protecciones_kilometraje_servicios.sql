-- ==============================================================================
-- Flyway Migration: V6__tarifas_protecciones_kilometraje_servicios.sql
-- Historia: HU-BD-06 - Persistir Tarifas, Protecciones, Kilometraje y Servicios
-- ==============================================================================

-- 1. Actualización DDL de tabla coberturas_seguro
ALTER TABLE coberturas_seguro
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(50),
    ADD COLUMN IF NOT EXISTS deducible_monto_fijo NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (deducible_monto_fijo >= 0),
    ADD COLUMN IF NOT EXISTS deducible_porcentaje NUMERIC(5,2) DEFAULT 0 CHECK (deducible_porcentaje BETWEEN 0 AND 100),
    ADD COLUMN IF NOT EXISTS monto_maximo_cobertura NUMERIC(14,2) CHECK (monto_maximo_cobertura IS NULL OR monto_maximo_cobertura >= 0),
    ADD COLUMN IF NOT EXISTS es_obligatorio BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS beneficios JSONB,
    ADD COLUMN IF NOT EXISTS moneda CHAR(3) NOT NULL DEFAULT 'COP',
    ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),
    ADD COLUMN IF NOT EXISTS fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS fecha_fin TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE coberturas_seguro
    DROP CONSTRAINT IF EXISTS chk_coberturas_seguro_fechas;
ALTER TABLE coberturas_seguro
    ADD CONSTRAINT chk_coberturas_seguro_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio);
ALTER TABLE coberturas_seguro
    DROP CONSTRAINT IF EXISTS uq_coberturas_seguro_codigo;
ALTER TABLE coberturas_seguro
    ADD CONSTRAINT uq_coberturas_seguro_codigo UNIQUE (codigo);

-- 2. Actualización DDL de tabla planes_kilometraje
ALTER TABLE planes_kilometraje
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(50),
    ADD COLUMN IF NOT EXISTS tipo VARCHAR(30) NOT NULL DEFAULT 'LIMITADO' CHECK (tipo IN ('LIMITADO', 'ILIMITADO')),
    ADD COLUMN IF NOT EXISTS tarifa_km_excedente NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (tarifa_km_excedente >= 0),
    ADD COLUMN IF NOT EXISTS moneda CHAR(3) NOT NULL DEFAULT 'COP',
    ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),
    ADD COLUMN IF NOT EXISTS fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS fecha_fin TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE planes_kilometraje
    DROP CONSTRAINT IF EXISTS chk_planes_kilometraje_fechas;
ALTER TABLE planes_kilometraje
    ADD CONSTRAINT chk_planes_kilometraje_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio);
ALTER TABLE planes_kilometraje
    DROP CONSTRAINT IF EXISTS uq_planes_kilometraje_codigo;
ALTER TABLE planes_kilometraje
    ADD CONSTRAINT uq_planes_kilometraje_codigo UNIQUE (codigo);

-- 3. Actualización DDL de tabla servicios_adicionales
ALTER TABLE servicios_adicionales
    ADD COLUMN IF NOT EXISTS codigo VARCHAR(50),
    ADD COLUMN IF NOT EXISTS tipo_cobro VARCHAR(30) NOT NULL DEFAULT 'POR_DIA' CHECK (tipo_cobro IN ('POR_DIA', 'POR_EVENTO', 'POR_TRAYECTO')),
    ADD COLUMN IF NOT EXISTS moneda CHAR(3) NOT NULL DEFAULT 'COP',
    ADD COLUMN IF NOT EXISTS version INTEGER NOT NULL DEFAULT 1 CHECK (version >= 1),
    ADD COLUMN IF NOT EXISTS fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS fecha_fin TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE servicios_adicionales
    DROP CONSTRAINT IF EXISTS chk_servicios_adicionales_fechas;
ALTER TABLE servicios_adicionales
    ADD CONSTRAINT chk_servicios_adicionales_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio);
ALTER TABLE servicios_adicionales
    DROP CONSTRAINT IF EXISTS uq_servicios_adicionales_codigo;
ALTER TABLE servicios_adicionales
    ADD CONSTRAINT uq_servicios_adicionales_codigo UNIQUE (codigo);

-- 4. Creación de Tabla de Tarifas por Categoría y Temporada
CREATE TABLE IF NOT EXISTS tarifas_categoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    categoria_id UUID NOT NULL REFERENCES categorias_vehiculo(id) ON DELETE CASCADE,
    temporada VARCHAR(30) NOT NULL DEFAULT 'ESTANDAR' CHECK (temporada IN ('ESTANDAR', 'TEMPORADA_BAJA', 'TEMPORADA_MEDIA', 'TEMPORADA_ALTA', 'PROMOCIONAL')),
    tarifa_base_diaria NUMERIC(12,2) NOT NULL CHECK (tarifa_base_diaria >= 0),
    deposito_garantia NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (deposito_garantia >= 0),
    suplemento_km_ilimitado_diario NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (suplemento_km_ilimitado_diario >= 0),
    km_incluidos_dia INTEGER NOT NULL DEFAULT 200 CHECK (km_incluidos_dia > 0),
    tarifa_km_excedente NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (tarifa_km_excedente >= 0),
    moneda CHAR(3) NOT NULL DEFAULT 'COP',
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMPTZ,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (categoria_id, temporada, fecha_inicio),
    CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

-- 5. Actualización DDL de Tablas de Relación con Vehículos
ALTER TABLE vehiculo_coberturas_seguro
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE vehiculo_planes_kilometraje
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE vehiculo_servicios_adicionales
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 6. Vista Consolidada de Tarifas y Extras por Vehículo
CREATE OR REPLACE VIEW tarifas_completas_vehiculo AS
SELECT 
    v.id AS vehiculo_id,
    v.placa,
    v.modelo,
    c.nombre AS categoria,
    v.tarifa_diaria AS tarifa_base_km_limitado,
    v.km_incluidos_dia,
    v.tarifa_km_excedente,
    COALESCE(v.tarifa_km_ilimitado, v.tarifa_diaria + 20000) AS tarifa_km_ilimitado,
    c.deposito_garantia,
    'COP' AS moneda,
    (
        SELECT jsonb_agg(jsonb_build_object(
            'cobertura_id', cs.id,
            'codigo', cs.codigo,
            'nombre', cs.nombre,
            'tarifa_diaria', vcs.tarifa_diaria,
            'deducible_monto', cs.deducible_monto_fijo,
            'es_obligatorio', cs.es_obligatorio
        ))
        FROM vehiculo_coberturas_seguro vcs
        JOIN coberturas_seguro cs ON vcs.cobertura_id = cs.id
        WHERE vcs.vehiculo_id = v.id AND vcs.activo = TRUE
    ) AS coberturas_disponibles,
    (
        SELECT jsonb_agg(jsonb_build_object(
            'servicio_id', sa.id,
            'codigo', sa.codigo,
            'nombre', sa.nombre,
            'tarifa_diaria', vsa.tarifa_diaria,
            'tipo_cobro', sa.tipo_cobro
        ))
        FROM vehiculo_servicios_adicionales vsa
        JOIN servicios_adicionales sa ON vsa.servicio_adicional_id = sa.id
        WHERE vsa.vehiculo_id = v.id AND vsa.activo = TRUE
    ) AS servicios_adicionales_disponibles
FROM vehiculos v
JOIN categorias_vehiculo c ON v.categoria_id = c.id
WHERE v.activo = TRUE;

-- 7. Creación de Índices de Búsqueda y Filtrado

-- 1. Índices por Código y Estado
CREATE INDEX IF NOT EXISTS idx_coberturas_seguro_codigo ON coberturas_seguro(codigo);
CREATE INDEX IF NOT EXISTS idx_coberturas_seguro_activo ON coberturas_seguro(activo);
CREATE INDEX IF NOT EXISTS idx_coberturas_seguro_vigencia ON coberturas_seguro(fecha_inicio, fecha_fin, activo);

CREATE INDEX IF NOT EXISTS idx_planes_kilometraje_codigo ON planes_kilometraje(codigo);
CREATE INDEX IF NOT EXISTS idx_planes_kilometraje_tipo ON planes_kilometraje(tipo);
CREATE INDEX IF NOT EXISTS idx_planes_kilometraje_activo ON planes_kilometraje(activo);

CREATE INDEX IF NOT EXISTS idx_servicios_adicionales_codigo ON servicios_adicionales(codigo);
CREATE INDEX IF NOT EXISTS idx_servicios_adicionales_tipo_cobro ON servicios_adicionales(tipo_cobro);
CREATE INDEX IF NOT EXISTS idx_servicios_adicionales_activo ON servicios_adicionales(activo);

-- 2. Índices de Tarifas por Categoría y Temporada
CREATE INDEX IF NOT EXISTS idx_tarifas_categoria_cat_temp ON tarifas_categoria(categoria_id, temporada);
CREATE INDEX IF NOT EXISTS idx_tarifas_categoria_vigencia ON tarifas_categoria(fecha_inicio, fecha_fin, activo);

-- 3. Índices de Relaciones por Vehículo
CREATE INDEX IF NOT EXISTS idx_vehiculo_coberturas_veh ON vehiculo_coberturas_seguro(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_coberturas_cob ON vehiculo_coberturas_seguro(cobertura_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_planes_km_veh ON vehiculo_planes_kilometraje(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_planes_km_plan ON vehiculo_planes_kilometraje(plan_kilometraje_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_servicios_veh ON vehiculo_servicios_adicionales(vehiculo_id);
CREATE INDEX IF NOT EXISTS idx_vehiculo_servicios_srv ON vehiculo_servicios_adicionales(servicio_adicional_id);

-- 8. Inserción de Semillas Iniciales
-- 1. Inserción / Actualización de Coberturas de Seguro
INSERT INTO coberturas_seguro (
    codigo, nombre, descripcion, tarifa_diaria, deducible_monto_fijo,
    deducible_porcentaje, monto_maximo_cobertura, es_obligatorio, beneficios,
    moneda, version, fecha_inicio, activo
)
VALUES
    ('PROT_OBLIGATORIA', 'Protección Obligatoria', 'Responsabilidad civil extracontractual y cobertura básica con deducible obligatorio', 29000, 4760000, 10, 840000000, TRUE, '{"responsabilidad_civil":"Hasta $840 millones por evento","cobertura_colision_danos":"Básica con deducible","asistencia_carretera":"24/7 a nivel nacional","deducible_por_siniestro":"$4.760.000 COP","cobertura_cristales_llantas":false,"cobertura_hurto_total":false}'::jsonb, 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('PROT_TOTAL', 'Protección Total', 'Cobertura integral contra todo riesgo, cero deducible, cristales, llantas y asistencia VIP', 67000, 0, 0, 2000000000, FALSE, '{"responsabilidad_civil":"Hasta $2.000 millones ampliada","cobertura_colision_danos":"Todo riesgo 100%","asistencia_carretera":"VIP prioritaria 24/7 con grúa ilimitada","deducible_por_siniestro":"$0 COP (Cero Deducible)","cobertura_cristales_llantas":true,"cobertura_hurto_total":true}'::jsonb, 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('PROT_PREMIUM', 'Protección Premium / Cero Riesgo', 'Máxima protección con auto sustituto inmediato, conductor adicional y cobertura de equipaje', 89000, 0, 0, 5000000000, FALSE, '{"responsabilidad_civil":"Hasta $5.000 millones","cobertura_colision_danos":"Todo riesgo prémium","asistencia_carretera":"VIP Concierge 24/7","deducible_por_siniestro":"$0 COP","auto_sustituto":true,"conductor_adicional_gratis":true,"cobertura_equipaje_personal":true}'::jsonb, 'COP', 1, CURRENT_TIMESTAMP, TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    codigo = EXCLUDED.codigo,
    descripcion = EXCLUDED.descripcion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    deducible_monto_fijo = EXCLUDED.deducible_monto_fijo,
    deducible_porcentaje = EXCLUDED.deducible_porcentaje,
    monto_maximo_cobertura = EXCLUDED.monto_maximo_cobertura,
    es_obligatorio = EXCLUDED.es_obligatorio,
    beneficios = EXCLUDED.beneficios,
    moneda = EXCLUDED.moneda,
    version = EXCLUDED.version,
    activo = EXCLUDED.activo;

-- 2. Inserción / Actualización de Planes de Kilometraje
INSERT INTO planes_kilometraje (
    codigo, nombre, tipo, kilometros_incluidos, tarifa_diaria,
    tarifa_km_excedente, moneda, version, fecha_inicio, activo
)
VALUES
    ('KM_LIMITADO_200', 'Kilometraje Limitado (200 km/día)', 'LIMITADO', 200, 0, 800, 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('KM_ILIMITADO', 'Kilometraje Ilimitado', 'ILIMITADO', NULL, 20000, 0, 'COP', 1, CURRENT_TIMESTAMP, TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    codigo = EXCLUDED.codigo,
    tipo = EXCLUDED.tipo,
    kilometros_incluidos = EXCLUDED.kilometros_incluidos,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    moneda = EXCLUDED.moneda,
    version = EXCLUDED.version,
    activo = EXCLUDED.activo;

-- 3. Inserción / Actualización de Servicios Adicionales (Extras)
INSERT INTO servicios_adicionales (
    codigo, nombre, descripcion, tarifa_diaria, tipo_cobro,
    moneda, version, fecha_inicio, activo
)
VALUES
    ('SRV_GPS', 'GPS Integrado / Navegador Satelital', 'Dispositivo GPS de última generación con mapas sin conexión y alertas de tráfico en tiempo real', 15000, 'POR_DIA', 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('SRV_SILLA_BEBE', 'Silla de Bebé / Asiento Infantil', 'Silla homologada de seguridad infantil ISOFIX para diferentes edades y pesos', 20000, 'POR_DIA', 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('SRV_CONDUCTOR_ADICIONAL', 'Conductor Adicional', 'Autorización legal y seguro extendido para un segundo conductor registrado', 30000, 'POR_DIA', 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('SRV_LAVADO_POST_ENTREGA', 'Lavado de Auto Post-Entrega', 'Servicio de limpieza y desinfección integral para entregar el vehículo sin preocuparse por el lavado', 25000, 'POR_EVENTO', 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('SRV_TANQUE_VACIO', 'Devolución con Tanque Vacío / Prepago Combustible', 'Opción de prepago de combustible para devolver el auto sin necesidad de tanquear antes de la entrega', 50000, 'POR_EVENTO', 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('SRV_WIFI_PORTATIL', 'WiFi Portátil / Hotspot 4G LTE', 'Módem portátil 4G con datos ilimitados para conectar hasta 5 dispositivos simultáneamente', 18000, 'POR_DIA', 'COP', 1, CURRENT_TIMESTAMP, TRUE),
    ('SRV_ENTREGA_OTRA_CIUDAD', 'Entrega en Otra Ciudad / Drop-off Nacional', 'Permite retirar el vehículo en una ciudad o sede y entregarlo en una sede diferente de Colombia', 50000, 'POR_TRAYECTO', 'COP', 1, CURRENT_TIMESTAMP, TRUE)
ON CONFLICT (nombre) DO UPDATE
SET
    codigo = EXCLUDED.codigo,
    descripcion = EXCLUDED.descripcion,
    tarifa_diaria = EXCLUDED.tarifa_diaria,
    tipo_cobro = EXCLUDED.tipo_cobro,
    moneda = EXCLUDED.moneda,
    version = EXCLUDED.version,
    activo = EXCLUDED.activo;

-- 4. Inserción de Tarifas Base por Categoría
INSERT INTO tarifas_categoria (
    categoria_id, temporada, tarifa_base_diaria, deposito_garantia,
    suplemento_km_ilimitado_diario, km_incluidos_dia, tarifa_km_excedente,
    moneda, fecha_inicio, activo
)
VALUES
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'SEDAN'), 'ESTANDAR', 85000, 500000, 20000, 200, 800, 'COP', CURRENT_TIMESTAMP, TRUE),
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'SUV'), 'ESTANDAR', 120000, 800000, 30000, 200, 1200, 'COP', CURRENT_TIMESTAMP, TRUE),
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'ECONOMICO'), 'ESTANDAR', 65000, 400000, 15000, 200, 700, 'COP', CURRENT_TIMESTAMP, TRUE),
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'DEPORTIVO'), 'ESTANDAR', 220000, 1500000, 50000, 200, 2500, 'COP', CURRENT_TIMESTAMP, TRUE),
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'COMPACTO'), 'ESTANDAR', 70000, 450000, 18000, 200, 750, 'COP', CURRENT_TIMESTAMP, TRUE),
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'PICKUP'), 'ESTANDAR', 160000, 1000000, 35000, 200, 1500, 'COP', CURRENT_TIMESTAMP, TRUE),
    ((SELECT id FROM categorias_vehiculo WHERE codigo = 'VAN'), 'ESTANDAR', 180000, 1200000, 40000, 200, 1800, 'COP', CURRENT_TIMESTAMP, TRUE)
ON CONFLICT (categoria_id, temporada, fecha_inicio) DO UPDATE
SET
    tarifa_base_diaria = EXCLUDED.tarifa_base_diaria,
    deposito_garantia = EXCLUDED.deposito_garantia,
    suplemento_km_ilimitado_diario = EXCLUDED.suplemento_km_ilimitado_diario,
    km_incluidos_dia = EXCLUDED.km_incluidos_dia,
    tarifa_km_excedente = EXCLUDED.tarifa_km_excedente,
    moneda = EXCLUDED.moneda,
    activo = EXCLUDED.activo;

-- 5. Asignación de Coberturas, Planes de KM y Servicios por Vehículo

-- 5.1 Asignación de Coberturas de Seguro a todos los vehículos de la flota
INSERT INTO vehiculo_coberturas_seguro (vehiculo_id, cobertura_id, tarifa_diaria, activo)
SELECT v.id, c.id, c.tarifa_diaria, TRUE
FROM vehiculos v
CROSS JOIN coberturas_seguro c
ON CONFLICT (vehiculo_id, cobertura_id) DO UPDATE 
SET tarifa_diaria = EXCLUDED.tarifa_diaria, activo = EXCLUDED.activo;

-- 5.2 Asignación de Planes de Kilometraje a todos los vehículos de la flota
INSERT INTO vehiculo_planes_kilometraje (vehiculo_id, plan_kilometraje_id, tarifa_diaria, tarifa_kilometro_excedente, activo)
SELECT 
    v.id, 
    p.id, 
    CASE WHEN p.tipo = 'ILIMITADO' THEN COALESCE(v.tarifa_km_ilimitado, 20000) ELSE 0 END,
    CASE WHEN p.tipo = 'LIMITADO' THEN COALESCE(v.tarifa_km_excedente, 800) ELSE 0 END,
    TRUE
FROM vehiculos v
CROSS JOIN planes_kilometraje p
ON CONFLICT (vehiculo_id, plan_kilometraje_id) DO UPDATE 
SET tarifa_diaria = EXCLUDED.tarifa_diaria, tarifa_kilometro_excedente = EXCLUDED.tarifa_kilometro_excedente, activo = EXCLUDED.activo;

-- 5.3 Asignación de Servicios Adicionales (Extras) a todos los vehículos de la flota
INSERT INTO vehiculo_servicios_adicionales (vehiculo_id, servicio_adicional_id, tarifa_diaria, activo)
SELECT v.id, s.id, s.tarifa_diaria, TRUE
FROM vehiculos v
CROSS JOIN servicios_adicionales s
ON CONFLICT (vehiculo_id, servicio_adicional_id) DO UPDATE 
SET tarifa_diaria = EXCLUDED.tarifa_diaria, activo = EXCLUDED.activo;

