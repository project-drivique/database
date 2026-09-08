-- ==============================================================================
-- Drivique - Rollback de Tablas (DDL Reversal)
-- ==============================================================================

-- 5. Auditoría
DROP TABLE IF EXISTS auditoria CASCADE;

-- 4. Pagos, Calificaciones y Notificaciones
DROP TABLE IF EXISTS colores_configuracion_marca CASCADE;
DROP TABLE IF EXISTS configuraciones_marca CASCADE;
DROP TABLE IF EXISTS reportes_generados CASCADE;
DROP TABLE IF EXISTS tipos_reporte_administrativo CASCADE;
DROP TABLE IF EXISTS reserva_promociones CASCADE;
DROP TABLE IF EXISTS promociones CASCADE;
DROP TABLE IF EXISTS respuestas_reporte_incidencia CASCADE;
DROP TABLE IF EXISTS reportes_incidencia CASCADE;
DROP TABLE IF EXISTS estados_reporte_incidencia CASCADE;
DROP TABLE IF EXISTS notificaciones CASCADE;
DROP TABLE IF EXISTS estados_notificacion CASCADE;
DROP TABLE IF EXISTS canales_notificacion CASCADE;
DROP TABLE IF EXISTS calificaciones_vehiculo CASCADE;
DROP TABLE IF EXISTS metodos_pago_guardados CASCADE;
DROP TABLE IF EXISTS solicitudes_extension_alquiler CASCADE;
DROP TABLE IF EXISTS comprobantes_pago CASCADE;
DROP TABLE IF EXISTS pagos CASCADE;
DROP TABLE IF EXISTS estados_pago CASCADE;
DROP TABLE IF EXISTS metodos_pago CASCADE;

-- 3. Reservas, Contratos e Inspecciones
DROP TABLE IF EXISTS respuestas_checklist_inspeccion CASCADE;
DROP TABLE IF EXISTS items_checklist_inspeccion CASCADE;
DROP TABLE IF EXISTS inspecciones_vehiculo CASCADE;
DROP TABLE IF EXISTS tipos_inspeccion CASCADE;
DROP TABLE IF EXISTS contrato_clausulas CASCADE;
DROP TABLE IF EXISTS clausulas_contrato CASCADE;
DROP TABLE IF EXISTS contratos_alquiler CASCADE;
DROP TABLE IF EXISTS estados_contrato CASCADE;
DROP TABLE IF EXISTS reserva_servicios_adicionales CASCADE;
DROP TABLE IF EXISTS puntos_reserva CASCADE;
DROP TABLE IF EXISTS reservas CASCADE;
DROP TABLE IF EXISTS estados_reserva CASCADE;

-- 2. Catálogo y Flota
DROP TABLE IF EXISTS mantenimientos_vehiculo CASCADE;
DROP TABLE IF EXISTS tipos_mantenimiento CASCADE;
DROP TABLE IF EXISTS vehiculo_planes_kilometraje CASCADE;
DROP TABLE IF EXISTS vehiculo_coberturas_seguro CASCADE;
DROP TABLE IF EXISTS vehiculo_servicios_adicionales CASCADE;
DROP TABLE IF EXISTS planes_kilometraje CASCADE;
DROP TABLE IF EXISTS coberturas_seguro CASCADE;
DROP TABLE IF EXISTS servicios_adicionales CASCADE;
DROP TABLE IF EXISTS favoritos_vehiculo CASCADE;
DROP TABLE IF EXISTS vehiculo_caracteristicas CASCADE;
DROP TABLE IF EXISTS caracteristicas CASCADE;
DROP TABLE IF EXISTS documentos_vehiculo CASCADE;
DROP TABLE IF EXISTS imagenes_vehiculo CASCADE;
DROP TABLE IF EXISTS vehiculos CASCADE;
DROP TABLE IF EXISTS usuario_sucursales CASCADE;
DROP TABLE IF EXISTS sedes CASCADE;
DROP TABLE IF EXISTS ciudades CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;
DROP TABLE IF EXISTS estados_vehiculo CASCADE;
DROP TABLE IF EXISTS tipos_combustible CASCADE;
DROP TABLE IF EXISTS tipos_transmision CASCADE;
DROP TABLE IF EXISTS categorias_vehiculo CASCADE;
DROP TABLE IF EXISTS marcas CASCADE;

-- 1. Seguridad y Usuarios
DROP TABLE IF EXISTS consentimientos_usuario CASCADE;
DROP TABLE IF EXISTS documentos_usuario CASCADE;
DROP TABLE IF EXISTS estados_documento_usuario CASCADE;
DROP TABLE IF EXISTS tipos_documento_usuario CASCADE;
DROP TABLE IF EXISTS codigos_verificacion CASCADE;
DROP TABLE IF EXISTS sesiones_usuario CASCADE;
DROP TABLE IF EXISTS configuracion_seguridad CASCADE;
DROP TABLE IF EXISTS politicas_contrasena CASCADE;
DROP TABLE IF EXISTS rol_permisos CASCADE;
DROP TABLE IF EXISTS usuario_roles CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS nacionalidades CASCADE;
DROP TABLE IF EXISTS permisos CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
