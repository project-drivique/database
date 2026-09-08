-- ==============================================================================
-- Drivique - Índices de Vehículos, Catálogo y Disponibilidad (DDL)
-- Historia: HU-BD-05 - Persistir Categorías, Vehículos, Características y Disponibilidad
-- ==============================================================================

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
