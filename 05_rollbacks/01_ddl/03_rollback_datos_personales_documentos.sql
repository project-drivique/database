-- ==============================================================================
-- Drivique - Rollback HU-BD-03: Datos Personales y Documentos
-- ==============================================================================

-- 1. Eliminación de Índices
DROP INDEX IF EXISTS idx_consentimientos_usuario_id;
DROP INDEX IF EXISTS idx_historial_verificacion_doc_id;
DROP INDEX IF EXISTS idx_documentos_usuario_tipo_id;
DROP INDEX IF EXISTS idx_documentos_usuario_estado_id;
DROP INDEX IF EXISTS idx_documentos_usuario_usuario_id;
DROP INDEX IF EXISTS idx_perfiles_usuario_usuario_id;

-- 2. Eliminación de Tablas Específicas
DROP TABLE IF EXISTS historial_verificacion_documentos CASCADE;
DROP TABLE IF EXISTS perfiles_usuario CASCADE;

-- 3. Limpieza de Semillas de Documentos
DELETE FROM estados_documento_usuario;
DELETE FROM tipos_documento_usuario;
