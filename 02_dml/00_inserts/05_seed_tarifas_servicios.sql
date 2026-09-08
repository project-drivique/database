-- ==============================================================================
-- Drivique - Semillas de Tarifas, Protecciones, Kilometraje y Servicios (DML)
-- Historia: HU-BD-06 - Persistir Tarifas, Protecciones, Kilometraje y Servicios
-- ==============================================================================

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

