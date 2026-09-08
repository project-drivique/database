-- ==============================================================================
-- Drivique - Suite de Pruebas Automatizadas: HU-BD-02 Usuarios, Roles y Tokens
-- ==============================================================================

\echo '=== 1. Creando Datos de Prueba: Nacionalidad y Usuario ==='
INSERT INTO nacionalidades (nombre, codigo_iso)
VALUES ('Colombia Test', 'CT')
ON CONFLICT (nombre) DO NOTHING;

-- Inserción de usuario con password hasheado (pgcrypto blowfish) y estado_cuenta
INSERT INTO usuarios (
    nombres,
    apellidos,
    email,
    telefono,
    documento_tipo,
    documento_numero,
    fecha_nacimiento,
    nacionalidad_id,
    password_hash,
    estado_cuenta,
    activo,
    perfil_completo
)
VALUES (
    'Alejandro',
    'Gomez',
    'alejandro.gomez@drivique.com',
    '+573009876543',
    'CC',
    '1098765432',
    '1992-08-20',
    (SELECT id FROM nacionalidades WHERE codigo_iso = 'CT'),
    crypt('ClaveUltraSegura2026!', gen_salt('bf', 8)),
    'ACTIVA',
    TRUE,
    TRUE
)
ON CONFLICT (email) DO UPDATE
SET
    estado_cuenta = 'ACTIVA',
    password_hash = crypt('ClaveUltraSegura2026!', gen_salt('bf', 8));

\echo '=== 2. Validando Autenticacion Segura (Hash no reversible en DB) ==='
SELECT
    id,
    nombres,
    email,
    estado_cuenta,
    (password_hash = crypt('ClaveUltraSegura2026!', password_hash)) AS password_valido,
    (password_hash = crypt('ClaveIncorrecta!', password_hash)) AS rechazo_clave_invalida
FROM usuarios
WHERE email = 'alejandro.gomez@drivique.com';

\echo '=== 3. Validando Asignacion Normalizada Usuario-Rol-Permiso ==='
-- Asignar rol ROLE_CUSTOMER
INSERT INTO usuario_roles (usuario_id, rol_id)
SELECT u.id, r.id
FROM usuarios u, roles r
WHERE u.email = 'alejandro.gomez@drivique.com' AND r.codigo = 'ROLE_CUSTOMER'
ON CONFLICT (usuario_id, rol_id) DO NOTHING;

-- Consultar permisos efectivos del usuario mediante JOIN relacional
SELECT
    u.email,
    r.codigo AS rol,
    p.codigo AS permiso_efectivo,
    p.nombre AS descripcion_permiso
FROM usuarios u
JOIN usuario_roles ur ON u.id = ur.usuario_id
JOIN roles r ON ur.rol_id = r.id
JOIN rol_permisos rp ON r.id = rp.rol_id
JOIN permisos p ON rp.permiso_id = p.id
WHERE u.email = 'alejandro.gomez@drivique.com'
ORDER BY p.codigo;

\echo '=== 4. Validando Ciclo de Vida de Refresh Tokens y Sesiones ==='
-- Inserción de sesion con token hasheado (SHA-256), dispositivo y expiracion
INSERT INTO sesiones_usuario (
    usuario_id,
    refresh_token_hash,
    dispositivo_info,
    ip_origen,
    user_agent,
    revocado,
    inicio_at,
    expira_at
)
SELECT
    u.id,
    encode(digest('refresh_token_aleatorio_seguro_xyz_123', 'sha256'), 'hex'),
    'iPhone 15 Pro - iOS 18',
    '192.168.1.50'::inet,
    'DriviqueMobileApp/1.0 (iOS; Build 42)',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days'
FROM usuarios u
WHERE u.email = 'alejandro.gomez@drivique.com'
ON CONFLICT (refresh_token_hash) DO NOTHING;

-- Consultar sesion activa por token_hash
SELECT
    s.id,
    s.refresh_token_hash,
    s.dispositivo_info,
    s.revocado,
    (s.expira_at > CURRENT_TIMESTAMP) AS token_vigente
FROM sesiones_usuario s
JOIN usuarios u ON s.usuario_id = u.id
WHERE u.email = 'alejandro.gomez@drivique.com';

-- Revocar sesion
UPDATE sesiones_usuario
SET
    revocado = TRUE,
    revocada_at = CURRENT_TIMESTAMP
WHERE refresh_token_hash = encode(digest('refresh_token_aleatorio_seguro_xyz_123', 'sha256'), 'hex');

-- Confirmar revocación
SELECT
    refresh_token_hash,
    dispositivo_info,
    revocado,
    revocada_at
FROM sesiones_usuario
WHERE refresh_token_hash = encode(digest('refresh_token_aleatorio_seguro_xyz_123', 'sha256'), 'hex');

\echo '=== 5. Validando Existencia y Uso de Indices Requeridos ==='
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'roles', 'permisos', 'usuario_roles', 'rol_permisos', 'sesiones_usuario')
ORDER BY tablename, indexname;

\echo '=== 6. Validando Rendimiento de Consulta con Index Scan ==='
EXPLAIN SELECT id, email, estado_cuenta FROM usuarios WHERE email = 'alejandro.gomez@drivique.com';
EXPLAIN SELECT id, refresh_token_hash, revocado FROM sesiones_usuario WHERE refresh_token_hash = encode(digest('test', 'sha256'), 'hex');

\echo '=== Suite de Pruebas HU-BD-02 Completada con Éxito ==='
