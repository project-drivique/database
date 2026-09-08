-- ==============================================================================
-- Drivique - Índices de Tarifas, Protecciones y Servicios (DDL)
-- Historia: HU-BD-06 - Persistir Tarifas, Protecciones, Kilometraje y Servicios
-- ==============================================================================

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
