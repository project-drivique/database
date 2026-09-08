-- ==============================================================================
-- Drivique - Rollback HU-BD-04: Ciudades y Sucursales
-- ==============================================================================

-- 1. Eliminación de Vista de Compatibilidad
DROP VIEW IF EXISTS sucursales;

-- 2. Eliminación de Índices de Búsqueda
DROP INDEX IF EXISTS idx_sedes_es_terminal;
DROP INDEX IF EXISTS idx_sedes_es_aeropuerto;
DROP INDEX IF EXISTS idx_sedes_permite_pago_efectivo;
DROP INDEX IF EXISTS idx_sedes_ciudad_activo;
DROP INDEX IF EXISTS idx_sedes_activo;
DROP INDEX IF EXISTS idx_sedes_ciudad_id;
DROP INDEX IF EXISTS idx_sedes_nombre;

DROP INDEX IF EXISTS idx_ciudades_dept_activo;
DROP INDEX IF EXISTS idx_ciudades_departamento_id;
DROP INDEX IF EXISTS idx_ciudades_activo;
DROP INDEX IF EXISTS idx_ciudades_nombre;

-- 3. Limpieza de Semillas
DELETE FROM sedes;
DELETE FROM ciudades;
DELETE FROM departamentos;
