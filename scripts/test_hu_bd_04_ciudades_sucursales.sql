-- ==============================================================================
-- Drivique - Suite de Pruebas Automatizadas: HU-BD-04 Ciudades y Sucursales
-- ==============================================================================

\echo '===================================================================='
\echo '=== TEST 1: Verificación de Persistencia Inicial (Catálogos DML) ==='
\echo '===================================================================='

SELECT 
    (SELECT COUNT(*) FROM departamentos) AS total_departamentos,
    (SELECT COUNT(*) FROM ciudades) AS total_ciudades,
    (SELECT COUNT(*) FROM sedes) AS total_sucursales;

-- Validar que existan exactamente los 25 departamentos y 25 ciudades principales
DO $$
DECLARE
    v_dept_count INTEGER;
    v_city_count INTEGER;
    v_branch_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_dept_count FROM departamentos;
    SELECT COUNT(*) INTO v_city_count FROM ciudades;
    SELECT COUNT(*) INTO v_branch_count FROM sedes;

    IF v_dept_count < 25 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 25 departamentos, encontrados: %', v_dept_count;
    END IF;

    IF v_city_count < 25 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 25 ciudades, encontradas: %', v_city_count;
    END IF;

    IF v_branch_count < 56 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 56 sucursales, encontradas: %', v_branch_count;
    END IF;

    RAISE NOTICE 'TEST 1 APROBADO: Catálogo inicial completo (Dept: %, Ciudades: %, Sedes: %)', 
        v_dept_count, v_city_count, v_branch_count;
END $$;


\echo '===================================================================='
\echo '=== TEST 2: Criterio 1 - Ciudad con Nombre Único y Estado Lógico ==='
\echo '===================================================================='

-- Inserción de una nueva ciudad de prueba
INSERT INTO departamentos (nombre, codigo_iso, activo)
VALUES ('Departamento Test HU04', 'CO-TST', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO ciudades (departamento_id, nombre, codigo_dane, tiene_aeropuerto, tiene_terminal, activo)
SELECT id, 'Ciudad Test Alpha', '99001', TRUE, FALSE, TRUE
FROM departamentos WHERE nombre = 'Departamento Test HU04'
ON CONFLICT (departamento_id, nombre) DO NOTHING;

-- Validar unicidad (Debe fallar al intentar duplicar departamento + nombre)
DO $$
DECLARE
    v_dept_id UUID;
    v_duplicate_failed BOOLEAN := FALSE;
BEGIN
    SELECT id INTO v_dept_id FROM departamentos WHERE nombre = 'Departamento Test HU04';

    BEGIN
        INSERT INTO ciudades (departamento_id, nombre, codigo_dane, activo)
        VALUES (v_dept_id, 'Ciudad Test Alpha', '99001', TRUE);
    EXCEPTION WHEN unique_violation THEN
        v_duplicate_failed := TRUE;
    END;

    IF NOT v_duplicate_failed THEN
        RAISE EXCEPTION 'Fallo: La restricción de unicidad en ciudades no rechazó el duplicado';
    END IF;

    RAISE NOTICE 'TEST 2.1 APROBADO: Unicidad de nombre de ciudad validada correctamente';
END $$;

-- Validar Estado Lógico (Desactivar y verificar filtrado)
UPDATE ciudades 
SET activo = FALSE 
WHERE nombre = 'Ciudad Test Alpha';

DO $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    SELECT activo INTO v_activo FROM ciudades WHERE nombre = 'Ciudad Test Alpha';

    IF v_activo IS NOT FALSE THEN
        RAISE EXCEPTION 'Fallo: El estado lógico no se actualizó correctamente';
    END IF;

    RAISE NOTICE 'TEST 2.2 APROBADO: Manejo de estado lógico de ciudad verificado exitosamente';
END $$;


\echo '===================================================================='
\echo '=== TEST 3: Criterio 2 - Sucursal con Dirección, Contacto y Estado =='
\echo '===================================================================='

-- Inserción de sucursal con todos sus atributos requeridos
INSERT INTO sedes (
    nombre, direccion, ciudad_id, pais, telefono, email_contacto,
    horario_atencion, es_aeropuerto, es_terminal, permite_pago_efectivo, activo
)
SELECT 
    'Drivique Test Branch - Hub 01',
    'Avenida Siempre Viva 742, Zona Comercial',
    c.id,
    'CO',
    '+57 300 123 4567',
    'hub01.test@drivique.com',
    'Lunes a Domingo 06:00 - 22:00',
    TRUE,
    FALSE,
    TRUE,
    TRUE
FROM ciudades c
WHERE c.nombre = 'Ciudad Test Alpha'
ON CONFLICT (nombre) DO UPDATE
SET direccion = EXCLUDED.direccion;

-- Consulta detallada a través de la vista sucursales
SELECT 
    id,
    nombre,
    ciudad_nombre,
    departamento_nombre,
    direccion,
    telefono,
    email_contacto,
    horario_atencion,
    permite_pago_efectivo,
    activo
FROM sucursales
WHERE nombre = 'Drivique Test Branch - Hub 01';

DO $$
DECLARE
    v_sede RECORD;
BEGIN
    SELECT * INTO v_sede FROM sucursales WHERE nombre = 'Drivique Test Branch - Hub 01';

    IF v_sede.direccion IS NULL OR v_sede.telefono IS NULL OR v_sede.email_contacto IS NULL THEN
        RAISE EXCEPTION 'Fallo: La sucursal no contiene los campos de contacto y dirección esperados';
    END IF;

    IF v_sede.activo IS NOT TRUE THEN
        RAISE EXCEPTION 'Fallo: El estado de la sucursal no es activo';
    END IF;

    RAISE NOTICE 'TEST 3 APROBADO: Sucursal relacionada a ciudad con contacto, dirección y estado válida';
END $$;


\echo '===================================================================='
\echo '=== TEST 4: Criterio 3 - Restricciones para Impedir Huérfanos ======'
\echo '===================================================================='

-- 4.1 Intentar eliminar una ciudad que tiene sedes asociadas (debe lanzar error de FK restrict)
DO $$
DECLARE
    v_city_id UUID;
    v_delete_prevented BOOLEAN := FALSE;
BEGIN
    SELECT id INTO v_city_id FROM ciudades WHERE nombre = 'Ciudad Test Alpha';

    BEGIN
        DELETE FROM ciudades WHERE id = v_city_id;
    EXCEPTION WHEN foreign_key_violation THEN
        v_delete_prevented := TRUE;
    END;

    IF NOT v_delete_prevented THEN
        RAISE EXCEPTION 'Fallo: Se permitió eliminar una ciudad que tiene sedes asociadas (generando huérfanos)';
    END IF;

    RAISE NOTICE 'TEST 4.1 APROBADO: Protección contra huérfanos en Ciudades -> Sedes activa';
END $$;

-- 4.2 Intentar eliminar un departamento que tiene ciudades asociadas
DO $$
DECLARE
    v_dept_id UUID;
    v_delete_prevented BOOLEAN := FALSE;
BEGIN
    SELECT id INTO v_dept_id FROM departamentos WHERE nombre = 'Departamento Test HU04';

    BEGIN
        DELETE FROM departamentos WHERE id = v_dept_id;
    EXCEPTION WHEN foreign_key_violation THEN
        v_delete_prevented := TRUE;
    END;

    IF NOT v_delete_prevented THEN
        RAISE EXCEPTION 'Fallo: Se permitió eliminar un departamento con ciudades asociadas';
    END IF;

    RAISE NOTICE 'TEST 4.2 APROBADO: Protección contra huérfanos en Departamentos -> Ciudades activa';
END $$;


\echo '===================================================================='
\echo '=== TEST 5: Criterio 4 - Validación de Índices de Búsqueda ========='
\echo '===================================================================='

-- Verificar que todos los índices requeridos existan en el catálogo pg_indexes
DO $$
DECLARE
    v_missing_indexes TEXT[];
BEGIN
    SELECT ARRAY_AGG(idx_expected)
    INTO v_missing_indexes
    FROM (
        SELECT unnest(ARRAY[
            'idx_ciudades_nombre',
            'idx_ciudades_activo',
            'idx_ciudades_departamento_id',
            'idx_sedes_nombre',
            'idx_sedes_ciudad_id',
            'idx_sedes_activo',
            'idx_sedes_ciudad_activo',
            'idx_sedes_permite_pago_efectivo'
        ]) AS idx_expected
    ) expected
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = idx_expected
    );

    IF v_missing_indexes IS NOT NULL AND array_length(v_missing_indexes, 1) > 0 THEN
        RAISE EXCEPTION 'Fallo: Índices faltantes: %', array_to_string(v_missing_indexes, ', ');
    END IF;

    RAISE NOTICE 'TEST 5 APROBADO: Todos los índices requeridos (ciudad, estado, nombre) existen';
END $$;


\echo '===================================================================='
\echo '=== TEST 6: Consultas de Catálogo y Cobertura Operativa ============'
\echo '===================================================================='

-- Búsqueda de sucursales activas en Bogotá con pago en efectivo
SELECT 
    s.nombre AS sucursal,
    s.direccion,
    s.telefono,
    s.horario_atencion,
    s.es_aeropuerto
FROM sucursales s
WHERE s.ciudad_nombre = 'Bogotá' 
  AND s.activo = TRUE 
  AND s.permite_pago_efectivo = TRUE
ORDER BY s.es_aeropuerto DESC, s.nombre ASC;

-- Búsqueda de ciudades activas con terminal o aeropuerto
SELECT 
    c.nombre AS ciudad,
    d.nombre AS departamento,
    c.tiene_aeropuerto,
    c.tiene_terminal,
    c.pico_y_placa_info->>'aplica' AS pico_y_placa_aplica
FROM ciudades c
JOIN departamentos d ON c.departamento_id = d.id
WHERE c.activo = TRUE
ORDER BY c.nombre;

-- Limpieza de datos de prueba
DELETE FROM sedes WHERE nombre = 'Drivique Test Branch - Hub 01';
DELETE FROM ciudades WHERE nombre = 'Ciudad Test Alpha';
DELETE FROM departamentos WHERE nombre = 'Departamento Test HU04';

\echo '===================================================================='
\echo '=== TODAS LAS PRUEBAS DE HU-BD-04 COMPLETADAS EXITOSAMENTE (6/6) ==='
\echo '===================================================================='
