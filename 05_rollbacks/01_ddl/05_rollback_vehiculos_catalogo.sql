-- ==============================================================================
-- Drivique - Rollback HU-BD-05: Categorías, Vehículos, Características y Disponibilidad
-- ==============================================================================

-- 1. Eliminación de Vista de Catálogo
DROP VIEW IF EXISTS catalogo_vehiculos;

-- 2. Eliminación de Índices de Búsqueda y Filtrado
DROP INDEX IF EXISTS idx_comentarios_vehiculo_veh_id;
DROP INDEX IF EXISTS idx_disponibilidad_vehiculo_rango;
DROP INDEX IF EXISTS idx_imagenes_vehiculo_veh_ord;
DROP INDEX IF EXISTS idx_vehiculo_caracteristicas_car;
DROP INDEX IF EXISTS idx_vehiculo_caracteristicas_veh;
DROP INDEX IF EXISTS idx_vehiculos_catalogo_busqueda;
DROP INDEX IF EXISTS idx_vehiculos_destacado;
DROP INDEX IF EXISTS idx_vehiculos_activo;
DROP INDEX IF EXISTS idx_vehiculos_disponible;
DROP INDEX IF EXISTS idx_vehiculos_combustible_id;
DROP INDEX IF EXISTS idx_vehiculos_transmision_id;
DROP INDEX IF EXISTS idx_vehiculos_estado_id;
DROP INDEX IF EXISTS idx_vehiculos_marca_id;
DROP INDEX IF EXISTS idx_vehiculos_sede_actual_id;
DROP INDEX IF EXISTS idx_vehiculos_categoria_id;
DROP INDEX IF EXISTS idx_vehiculos_vin;
DROP INDEX IF EXISTS idx_vehiculos_placa;

-- 3. Limpieza de Datos de Catálogo
DELETE FROM comentarios_vehiculo;
DELETE FROM disponibilidad_vehiculo;
DELETE FROM imagenes_vehiculo;
DELETE FROM vehiculo_caracteristicas;
DELETE FROM vehiculos;
DELETE FROM caracteristicas;
DELETE FROM estados_vehiculo;
DELETE FROM tipos_combustible;
DELETE FROM tipos_transmision;
DELETE FROM categorias_vehiculo;
DELETE FROM marcas;

-- 4. Eliminación de Tablas Específicas
DROP TABLE IF EXISTS comentarios_vehiculo CASCADE;
DROP TABLE IF EXISTS disponibilidad_vehiculo CASCADE;
