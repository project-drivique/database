-- ==============================================================================
-- Flyway Migration: V2__usuarios_roles_tokens.sql
-- Historia: HU-BD-02 - Usuarios, Roles y Tokens
-- ==============================================================================

-- 1. Actualización de tabla usuarios (Estado de cuenta)
ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS estado_cuenta VARCHAR(30) NOT NULL DEFAULT 'ACTIVA'
    CHECK (estado_cuenta IN ('ACTIVA', 'INACTIVA', 'SUSPENDIDA', 'BLOQUEADA', 'PENDIENTE_VERIFICACION'));

-- 2. Actualización de tabla sesiones_usuario (Dispositivo y Revocación de Tokens)
ALTER TABLE sesiones_usuario
    ADD COLUMN IF NOT EXISTS dispositivo_info VARCHAR(255),
    ADD COLUMN IF NOT EXISTS revocado BOOLEAN NOT NULL DEFAULT FALSE;

-- 3. Creación de Índices de Seguridad y Rendimiento
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_documento ON usuarios(documento_tipo, documento_numero);
CREATE INDEX IF NOT EXISTS idx_usuarios_estado_cuenta ON usuarios(estado_cuenta);
CREATE INDEX IF NOT EXISTS idx_roles_codigo ON roles(codigo);
CREATE INDEX IF NOT EXISTS idx_permisos_codigo ON permisos(codigo);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_usuario ON usuario_roles(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_rol ON usuario_roles(rol_id);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_rol ON rol_permisos(rol_id);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_permiso ON rol_permisos(permiso_id);
CREATE INDEX IF NOT EXISTS idx_sesiones_refresh_token_hash ON sesiones_usuario(refresh_token_hash);
CREATE INDEX IF NOT EXISTS idx_sesiones_usuario_id ON sesiones_usuario(usuario_id);
CREATE INDEX IF NOT EXISTS idx_sesiones_revocado ON sesiones_usuario(revocado);
CREATE INDEX IF NOT EXISTS idx_codigos_verificacion_usuario ON codigos_verificacion(usuario_id);
