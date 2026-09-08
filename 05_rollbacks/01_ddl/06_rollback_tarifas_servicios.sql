-- ==============================================================================
-- Drivique - Rollback HU-BD-06: Tarifas, Protecciones, Kilometraje y Servicios
-- ==============================================================================

-- 1. Eliminación de Vista de Tarifas
DROP VIEW IF EXISTS tarifas_completas_vehiculo;

-- 2. Eliminación de Índices
DROP INDEX IF EXISTS idx_vehiculo_servicios_srv;
DROP INDEX IF EXISTS idx_vehiculo_servicios_veh;
DROP INDEX IF EXISTS idx_vehiculo_planes_km_plan;
DROP INDEX IF EXISTS idx_vehiculo_planes_km_veh;
DROP INDEX IF EXISTS idx_vehiculo_coberturas_cob;
DROP INDEX IF EXISTS idx_vehiculo_coberturas_veh;
DROP INDEX IF EXISTS idx_tarifas_categoria_vigencia;
DROP INDEX IF EXISTS idx_tarifas_categoria_cat_temp;
DROP INDEX IF EXISTS idx_servicios_adicionales_activo;
DROP INDEX IF EXISTS idx_servicios_adicionales_tipo_cobro;
DROP INDEX IF EXISTS idx_servicios_adicionales_codigo;
DROP INDEX IF EXISTS idx_planes_kilometraje_activo;
DROP INDEX IF EXISTS idx_planes_kilometraje_tipo;
DROP INDEX IF EXISTS idx_planes_kilometraje_codigo;
DROP INDEX IF EXISTS idx_coberturas_seguro_vigencia;
DROP INDEX IF EXISTS idx_coberturas_seguro_activo;
DROP INDEX IF EXISTS idx_coberturas_seguro_codigo;

-- 3. Limpieza de Datos
DELETE FROM vehiculo_servicios_adicionales;
DELETE FROM vehiculo_planes_kilometraje;
DELETE FROM vehiculo_coberturas_seguro;
DELETE FROM tarifas_categoria;
DELETE FROM servicios_adicionales;
DELETE FROM planes_kilometraje;
DELETE FROM coberturas_seguro;

-- 4. Eliminación de Tablas Específicas
DROP TABLE IF EXISTS tarifas_categoria CASCADE;
