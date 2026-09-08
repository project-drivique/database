-- ==============================================================================
-- Drivique - Semillas de Catálogos de Documentos (DML)
-- ==============================================================================

-- 1. Tipos de Documento de Usuario
INSERT INTO tipos_documento_usuario (codigo, nombre, descripcion, requiere_reverso, activo)
VALUES
    ('CEDULA_CIUDADANIA', 'Cédula de Ciudadanía', 'Documento nacional de identidad para ciudadanos colombianos', TRUE, TRUE),
    ('CEDULA_EXTRANJERIA', 'Cédula de Extranjería', 'Documento de identidad para residentes extranjeros', TRUE, TRUE),
    ('PASAPORTE', 'Pasaporte Internacional', 'Documento de viaje e identificación internacional', FALSE, TRUE),
    ('LICENCIA_CONDUCCION', 'Licencia de Conducción', 'Permiso oficial para operar vehículos automotores', TRUE, TRUE),
    ('PERMISO_TEMPORAL_PERMANENCIA', 'Permiso Temporal de Permanencia (PPT)', 'Documento migratorio especial de permanencia', TRUE, TRUE)
ON CONFLICT (codigo) DO UPDATE
SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    requiere_reverso = EXCLUDED.requiere_reverso,
    activo = EXCLUDED.activo;

-- 2. Estados de Verificación de Documentos
INSERT INTO estados_documento_usuario (codigo, nombre, descripcion, activo)
VALUES
    ('PENDIENTE_REVISION', 'Pendiente de Revisión', 'El documento ha sido cargado y espera validación de un agente', TRUE),
    ('APROBADO', 'Aprobado y Verificado', 'El documento cumple todos los criterios de validez y vigencia', TRUE),
    ('RECHAZADO', 'Rechazado', 'El documento es ilegible, incompleto o no cumple las políticas', TRUE),
    ('EN_SUBSANACION', 'En Subsanación', 'Se ha solicitado al usuario corregir o subir nuevamente el documento', TRUE),
    ('VENCIDO', 'Vencido / Expirado', 'El documento ha superado su fecha límite de vigencia legal', TRUE)
ON CONFLICT (codigo) DO UPDATE
SET
    nombre = EXCLUDED.nombre,
    descripcion = EXCLUDED.descripcion,
    activo = EXCLUDED.activo;
