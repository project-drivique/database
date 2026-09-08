-- ==============================================================================
-- Drivique - Rollback HU-BD-02: Usuarios, Roles y Tokens
-- ==============================================================================

-- 1. Eliminación de Índices de Seguridad
DROP INDEX IF EXISTS idx_codigos_verificacion_usuario;
DROP INDEX IF EXISTS idx_sesiones_revocado;
DROP INDEX IF EXISTS idx_sesiones_usuario_id;
DROP INDEX IF EXISTS idx_sesiones_refresh_token_hash;
DROP INDEX IF EXISTS idx_rol_permisos_permiso;
DROP INDEX IF EXISTS idx_rol_permisos_rol;
DROP INDEX IF EXISTS idx_usuario_roles_rol;
DROP INDEX IF EXISTS idx_usuario_roles_usuario;
DROP INDEX IF EXISTS idx_permisos_codigo;
DROP INDEX IF EXISTS idx_roles_codigo;
DROP INDEX IF EXISTS idx_usuarios_estado_cuenta;
DROP INDEX IF EXISTS idx_usuarios_documento;
DROP INDEX IF EXISTS idx_usuarios_email;

-- 2. Limpieza de Semillas DML (Roles y Permisos iniciales)
DELETE FROM rol_permisos;
DELETE FROM usuario_roles;
DELETE FROM permisos;
DELETE FROM roles;
