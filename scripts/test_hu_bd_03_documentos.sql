-- ==============================================================================
-- Drivique - Suite de Pruebas Automatizadas: HU-BD-03 Datos Personales y Documentos
-- ==============================================================================

\echo '=== 1. Creando Datos de Prueba: Usuario y Verificador ==='
-- Usuario Cliente
INSERT INTO usuarios (
    nombres, apellidos, email, telefono, documento_tipo, documento_numero,
    fecha_nacimiento, password_hash, estado_cuenta
)
VALUES (
    'Mariana', 'Restrepo', 'mariana.restrepo@drivique.com', '+573105551234',
    'CC', '1037654321', '1996-03-12', '$2a$10$abcdefghijklmnopqrstuvwxyz123456', 'ACTIVA'
)
ON CONFLICT (email) DO NOTHING;

-- Usuario Verificador / Operador
INSERT INTO usuarios (
    nombres, apellidos, email, telefono, documento_tipo, documento_numero,
    fecha_nacimiento, password_hash, estado_cuenta
)
VALUES (
    'Fernando', 'Vallejo', 'fernando.operador@drivique.com', '+573105559999',
    'CC', '71234567', '1988-11-05', '$2a$10$abcdefghijklmnopqrstuvwxyz123456', 'ACTIVA'
)
ON CONFLICT (email) DO NOTHING;

\echo '=== 2. Validando Separacion de Perfil vs Credenciales ==='
INSERT INTO perfiles_usuario (
    usuario_id,
    direccion,
    ciudad_residencia,
    departamento_residencia,
    codigo_postal,
    genero,
    licencia_numero,
    licencia_categoria,
    licencia_expiracion,
    telefono_emergencia,
    contacto_emergencia_nombre,
    foto_perfil_referencia
)
SELECT
    u.id,
    'Calle 10 # 43E-20, El Poblado',
    'Medellin',
    'Antioquia',
    '050021',
    'FEMENINO',
    '05001-98765432',
    'B1',
    '2030-05-20'::date,
    '+573117778899',
    'Carlos Restrepo (Padre)',
    's3://drivique-media/avatars/user-mariana-uuid.webp'
FROM usuarios u
WHERE u.email = 'mariana.restrepo@drivique.com'
ON CONFLICT (usuario_id) DO UPDATE
SET
    direccion = EXCLUDED.direccion,
    licencia_numero = EXCLUDED.licencia_numero;

-- Consultar perfil separado
SELECT
    u.email,
    u.documento_tipo,
    u.documento_numero,
    p.ciudad_residencia,
    p.licencia_numero,
    p.licencia_categoria,
    p.licencia_expiracion,
    p.contacto_emergencia_nombre
FROM usuarios u
JOIN perfiles_usuario p ON u.id = p.usuario_id
WHERE u.email = 'mariana.restrepo@drivique.com';

\echo '=== 3. Validando Carga de Documento con Referencia Segura y Checksum ==='
INSERT INTO documentos_usuario (
    usuario_id,
    tipo_documento_id,
    estado_id,
    referencia_segura,
    referencia_segura_reverso,
    checksum_sha256,
    content_type,
    file_size_bytes,
    fecha_emision,
    fecha_expiracion
)
SELECT
    u.id,
    (SELECT id FROM tipos_documento_usuario WHERE codigo = 'LICENCIA_CONDUCCION'),
    (SELECT id FROM estados_documento_usuario WHERE codigo = 'PENDIENTE_REVISION'),
    's3://drivique-secure-docs/users/mariana/licencia_front_enc.pdf',
    's3://drivique-secure-docs/users/mariana/licencia_back_enc.pdf',
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    'application/pdf',
    1048576,
    '2020-05-20'::date,
    '2030-05-20'::date
FROM usuarios u
WHERE u.email = 'mariana.restrepo@drivique.com'
RETURNING id, referencia_segura, checksum_sha256, content_type;

\echo '=== 4. Validando Auditoria e Historial de Verificacion ==='
-- Transicion de estado: PENDIENTE_REVISION -> APROBADO
DO $$
DECLARE
    v_doc_id UUID;
    v_estado_prev UUID;
    v_estado_nuevo UUID;
    v_verificador_id UUID;
BEGIN
    SELECT d.id INTO v_doc_id
    FROM documentos_usuario d
    JOIN usuarios u ON d.usuario_id = u.id
    WHERE u.email = 'mariana.restrepo@drivique.com'
    LIMIT 1;

    SELECT id INTO v_estado_prev FROM estados_documento_usuario WHERE codigo = 'PENDIENTE_REVISION';
    SELECT id INTO v_estado_nuevo FROM estados_documento_usuario WHERE codigo = 'APROBADO';
    SELECT id INTO v_verificador_id FROM usuarios WHERE email = 'fernando.operador@drivique.com';

    -- 1. Actualizar estado del documento
    UPDATE documentos_usuario
    SET
        estado_id = v_estado_nuevo,
        observacion_revision = 'Documento legible, vigente y con categorias B1 y C1 validadas en RUNT.',
        revisado_por = v_verificador_id,
        revisado_at = CURRENT_TIMESTAMP
    WHERE id = v_doc_id;

    -- 2. Registrar en historial de auditoría
    INSERT INTO historial_verificacion_documentos (
        documento_id,
        estado_anterior_id,
        estado_nuevo_id,
        observaciones,
        verificado_por
    )
    VALUES (
        v_doc_id,
        v_estado_prev,
        v_estado_nuevo,
        'Aprobacion satisfactoria tras validacion biometrica y de RUNT.',
        v_verificador_id
    );
END
$$;

-- Consultar historial del documento
SELECT
    d.id AS documento_id,
    td.nombre AS tipo_documento,
    eprev.codigo AS estado_anterior,
    enew.codigo AS estado_nuevo,
    h.observaciones,
    u_verif.email AS verificado_por,
    h.verificado_at
FROM historial_verificacion_documentos h
JOIN documentos_usuario d ON h.documento_id = d.id
JOIN tipos_documento_usuario td ON d.tipo_documento_id = td.id
LEFT JOIN estados_documento_usuario eprev ON h.estado_anterior_id = eprev.id
JOIN estados_documento_usuario enew ON h.estado_nuevo_id = enew.id
JOIN usuarios u_verif ON h.verificado_por = u_verif.id;

\echo '=== 5. Validando Consentimientos de Privacidad (Habeas Data) ==='
INSERT INTO consentimientos_usuario (
    usuario_id,
    tipo,
    version_documento,
    ip_origen,
    user_agent,
    vigente
)
SELECT
    u.id,
    'TRATAMIENTO_DATOS_PERSONALES',
    'v2.0_2026',
    '181.129.54.10'::inet,
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)',
    TRUE
FROM usuarios u
WHERE u.email = 'mariana.restrepo@drivique.com'
ON CONFLICT (usuario_id, tipo, version_documento) DO NOTHING;

SELECT
    u.email,
    c.tipo AS politica_aceptada,
    c.version_documento,
    c.ip_origen,
    c.vigente,
    c.aceptado_at
FROM consentimientos_usuario c
JOIN usuarios u ON c.usuario_id = u.id
WHERE u.email = 'mariana.restrepo@drivique.com';

\echo '=== 6. Validando Uso de Indices en Consultas de Perfil y Documentos ==='
EXPLAIN SELECT * FROM perfiles_usuario WHERE usuario_id = '00000000-0000-0000-0000-000000000000';
EXPLAIN SELECT * FROM documentos_usuario WHERE usuario_id = '00000000-0000-0000-0000-000000000000';
EXPLAIN SELECT * FROM historial_verificacion_documentos WHERE documento_id = '00000000-0000-0000-0000-000000000000';

\echo '=== Suite de Pruebas HU-BD-03 Completada con Éxito ==='
