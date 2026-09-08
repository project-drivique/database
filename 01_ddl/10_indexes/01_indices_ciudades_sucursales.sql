-- ==============================================================================
-- Drivique - Índices de Ciudades y Sucursales (DDL)
-- Historia: HU-BD-04 - Persistir Ciudades y Sucursales
-- ==============================================================================

-- 1. Índices para Búsqueda y Filtrado en Ciudades
CREATE INDEX IF NOT EXISTS idx_ciudades_nombre ON ciudades(nombre);
CREATE INDEX IF NOT EXISTS idx_ciudades_activo ON ciudades(activo);
CREATE INDEX IF NOT EXISTS idx_ciudades_departamento_id ON ciudades(departamento_id);
CREATE INDEX IF NOT EXISTS idx_ciudades_dept_activo ON ciudades(departamento_id, activo);

-- 2. Índices para Búsqueda y Filtrado en Sedes / Sucursales
CREATE INDEX IF NOT EXISTS idx_sedes_nombre ON sedes(nombre);
CREATE INDEX IF NOT EXISTS idx_sedes_ciudad_id ON sedes(ciudad_id);
CREATE INDEX IF NOT EXISTS idx_sedes_activo ON sedes(activo);
CREATE INDEX IF NOT EXISTS idx_sedes_ciudad_activo ON sedes(ciudad_id, activo);
CREATE INDEX IF NOT EXISTS idx_sedes_permite_pago_efectivo ON sedes(permite_pago_efectivo);
CREATE INDEX IF NOT EXISTS idx_sedes_es_aeropuerto ON sedes(es_aeropuerto);
CREATE INDEX IF NOT EXISTS idx_sedes_es_terminal ON sedes(es_terminal);
