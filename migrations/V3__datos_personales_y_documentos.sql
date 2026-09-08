-- ==============================================================================
-- Flyway Migration: V3__datos_personales_y_documentos.sql
-- Historia: HU-BD-03 - Datos personales y documentos
-- ==============================================================================

-- 1. Tabla de Perfiles de Usuario (Separación de credenciales vs datos de perfil)
CREATE TABLE IF NOT EXISTS perfiles_usuario (
    usuario_id UUID PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
    direccion VARCHAR(255),
    ciudad_residencia VARCHAR(100),
    departamento_residencia VARCHAR(100),
    codigo_postal VARCHAR(20),
    genero VARCHAR(20) CHECK (genero IS NULL OR genero IN ('MASCULINO', 'FEMENINO', 'OTRO', 'PREFIERO_NO_DECIR')),
    licencia_numero VARCHAR(50),
    licencia_categoria VARCHAR(10),
    licencia_expiracion DATE,
    telefono_emergencia VARCHAR(30),
    contacto_emergencia_nombre VARCHAR(150),
    foto_perfil_referencia VARCHAR(1000),
    preferencias_notificacion JSONB DEFAULT '{"email": true, "sms": true, "push": true}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Ajuste a Catálogos de Documentos
ALTER TABLE tipos_documento_usuario
    ADD COLUMN IF NOT EXISTS descripcion VARCHAR(255),
    ADD COLUMN IF NOT EXISTS requiere_reverso BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE estados_documento_usuario
    ADD COLUMN IF NOT EXISTS descripcion VARCHAR(255),
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 3. Ajuste a Tabla Documentos Usuario (Flexibilizar url_anverso anterior y agregar Referencia Segura, Checksum SHA-256)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'documentos_usuario' AND column_name = 'url_anverso'
    ) THEN
        ALTER TABLE documentos_usuario ALTER COLUMN url_anverso DROP NOT NULL;
    END IF;
END $$;

ALTER TABLE documentos_usuario
    ADD COLUMN IF NOT EXISTS referencia_segura VARCHAR(1000),
    ADD COLUMN IF NOT EXISTS referencia_segura_reverso VARCHAR(1000),
    ADD COLUMN IF NOT EXISTS checksum_sha256 VARCHAR(64),
    ADD COLUMN IF NOT EXISTS content_type VARCHAR(100) NOT NULL DEFAULT 'application/pdf',
    ADD COLUMN IF NOT EXISTS file_size_bytes BIGINT,
    ADD COLUMN IF NOT EXISTS fecha_emision DATE,
    ADD COLUMN IF NOT EXISTS fecha_expiracion DATE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 4. Tabla de Historial de Verificación de Documentos
CREATE TABLE IF NOT EXISTS historial_verificacion_documentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    documento_id UUID NOT NULL REFERENCES documentos_usuario(id) ON DELETE CASCADE,
    estado_anterior_id UUID REFERENCES estados_documento_usuario(id),
    estado_nuevo_id UUID NOT NULL REFERENCES estados_documento_usuario(id),
    observaciones VARCHAR(500),
    motivo_rechazo VARCHAR(255),
    verificado_por UUID NOT NULL REFERENCES usuarios(id),
    verificado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Ajuste a Tabla de Consentimientos de Privacidad
ALTER TABLE consentimientos_usuario
    ADD COLUMN IF NOT EXISTS user_agent VARCHAR(500),
    ADD COLUMN IF NOT EXISTS vigente BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS revocado_at TIMESTAMPTZ;

-- 6. Índices de Rendimiento y Privacidad
CREATE INDEX IF NOT EXISTS idx_perfiles_usuario_usuario_id ON perfiles_usuario(usuario_id);
CREATE INDEX IF NOT EXISTS idx_documentos_usuario_usuario_id ON documentos_usuario(usuario_id);
CREATE INDEX IF NOT EXISTS idx_documentos_usuario_estado_id ON documentos_usuario(estado_id);
CREATE INDEX IF NOT EXISTS idx_documentos_usuario_tipo_id ON documentos_usuario(tipo_documento_id);
CREATE INDEX IF NOT EXISTS idx_historial_verificacion_doc_id ON historial_verificacion_documentos(documento_id);
CREATE INDEX IF NOT EXISTS idx_consentimientos_usuario_id ON consentimientos_usuario(usuario_id);
