-- ==============================================================================
-- Drivique - Suite de Pruebas Automatizadas: HU-BD-05 Categorías, Vehículos y Disponibilidad
-- ==============================================================================

\echo '===================================================================='
\echo '=== TEST 1: Verificación de Persistencia Inicial de Catálogo DML ==='
\echo '===================================================================='

SELECT 
    (SELECT COUNT(*) FROM marcas) AS total_marcas,
    (SELECT COUNT(*) FROM categorias_vehiculo) AS total_categorias,
    (SELECT COUNT(*) FROM estados_vehiculo) AS total_estados_operativos,
    (SELECT COUNT(*) FROM caracteristicas) AS total_caracteristicas,
    (SELECT COUNT(*) FROM vehiculos) AS total_vehiculos,
    (SELECT COUNT(*) FROM imagenes_vehiculo) AS total_imagenes,
    (SELECT COUNT(*) FROM comentarios_vehiculo) AS total_comentarios;

DO $$
DECLARE
    v_marcas INTEGER;
    v_categorias INTEGER;
    v_vehiculos INTEGER;
    v_imagenes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_marcas FROM marcas;
    SELECT COUNT(*) INTO v_categorias FROM categorias_vehiculo;
    SELECT COUNT(*) INTO v_vehiculos FROM vehiculos;
    SELECT COUNT(*) INTO v_imagenes FROM imagenes_vehiculo;

    IF v_marcas < 10 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 10 marcas, encontradas: %', v_marcas;
    END IF;

    IF v_categorias < 5 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 5 categorías, encontradas: %', v_categorias;
    END IF;

    IF v_vehiculos < 9 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 9 vehículos oficiales, encontrados: %', v_vehiculos;
    END IF;

    IF v_imagenes < 27 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 27 imágenes asociadas a la flota, encontradas: %', v_imagenes;
    END IF;

    RAISE NOTICE 'TEST 1 APROBADO: Catálogo inicial completo y persistido exitosamente';
END $$;


\echo '===================================================================='
\echo '=== TEST 2: Criterio 1 - Unicidad Estricta de Placa y VIN =========='
\echo '===================================================================='

-- 2.1 Validar duplicado de Placa (Debe fallar)
DO $$
DECLARE
    v_placa_dup_failed BOOLEAN := FALSE;
    v_marca_id UUID;
    v_cat_id UUID;
    v_trans_id UUID;
    v_comb_id UUID;
    v_est_id UUID;
    v_sede_id UUID;
BEGIN
    SELECT id INTO v_marca_id FROM marcas LIMIT 1;
    SELECT id INTO v_cat_id FROM categorias_vehiculo LIMIT 1;
    SELECT id INTO v_trans_id FROM tipos_transmision LIMIT 1;
    SELECT id INTO v_comb_id FROM tipos_combustible LIMIT 1;
    SELECT id INTO v_est_id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE' LIMIT 1;
    SELECT id INTO v_sede_id FROM sedes LIMIT 1;

    BEGIN
        INSERT INTO vehiculos (
            placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
            estado_id, sede_actual_id, modelo, anio, capacidad_pasajeros,
            tarifa_diaria
        )
        VALUES (
            'ABC-123', -- Placa ya existente del Toyota Corolla
            '935DUP00000000001',
            v_marca_id, v_cat_id, v_trans_id, v_comb_id, v_est_id, v_sede_id,
            'Vehículo Placa Duplicada', 2024, 5, 85000
        );
    EXCEPTION WHEN unique_violation THEN
        v_placa_dup_failed := TRUE;
    END;

    IF NOT v_placa_dup_failed THEN
        RAISE EXCEPTION 'Fallo: La restricción UNIQUE en placa no rechazó el duplicado';
    END IF;

    RAISE NOTICE 'TEST 2.1 APROBADO: Unicidad de placa validada correctamente';
END $$;

-- 2.2 Validar duplicado de VIN (Debe fallar)
DO $$
DECLARE
    v_vin_dup_failed BOOLEAN := FALSE;
    v_marca_id UUID;
    v_cat_id UUID;
    v_trans_id UUID;
    v_comb_id UUID;
    v_est_id UUID;
    v_sede_id UUID;
BEGIN
    SELECT id INTO v_marca_id FROM marcas LIMIT 1;
    SELECT id INTO v_cat_id FROM categorias_vehiculo LIMIT 1;
    SELECT id INTO v_trans_id FROM tipos_transmision LIMIT 1;
    SELECT id INTO v_comb_id FROM tipos_combustible LIMIT 1;
    SELECT id INTO v_est_id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE' LIMIT 1;
    SELECT id INTO v_sede_id FROM sedes LIMIT 1;

    BEGIN
        INSERT INTO vehiculos (
            placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
            estado_id, sede_actual_id, modelo, anio, capacidad_pasajeros,
            tarifa_diaria
        )
        VALUES (
            'ZZZ-999',
            '935ABCD1234567890', -- VIN ya existente del Toyota Corolla
            v_marca_id, v_cat_id, v_trans_id, v_comb_id, v_est_id, v_sede_id,
            'Vehículo VIN Duplicado', 2024, 5, 85000
        );
    EXCEPTION WHEN unique_violation THEN
        v_vin_dup_failed := TRUE;
    END;

    IF NOT v_vin_dup_failed THEN
        RAISE EXCEPTION 'Fallo: La restricción UNIQUE en VIN no rechazó el duplicado';
    END IF;

    RAISE NOTICE 'TEST 2.2 APROBADO: Unicidad de VIN validada correctamente';
END $$;


\echo '===================================================================='
\echo '=== TEST 3: Criterio 2 - Relaciones con Categoría y Sucursal ======='
\echo '===================================================================='

-- 3.1 Intentar eliminar una categoría con vehículos asociados (ON DELETE RESTRICT)
DO $$
DECLARE
    v_cat_id UUID;
    v_delete_prevented BOOLEAN := FALSE;
BEGIN
    SELECT id INTO v_cat_id FROM categorias_vehiculo WHERE nombre = 'Sedan';

    BEGIN
        DELETE FROM categorias_vehiculo WHERE id = v_cat_id;
    EXCEPTION WHEN foreign_key_violation THEN
        v_delete_prevented := TRUE;
    END;

    IF NOT v_delete_prevented THEN
        RAISE EXCEPTION 'Fallo: Se permitió eliminar una categoría con vehículos asociados';
    END IF;

    RAISE NOTICE 'TEST 3.1 APROBADO: Protección contra huérfanos Categoría -> Vehículo activa';
END $$;

-- 3.2 Intentar eliminar una sede con vehículos asociados (ON DELETE RESTRICT)
DO $$
DECLARE
    v_sede_id UUID;
    v_delete_prevented BOOLEAN := FALSE;
BEGIN
    SELECT sede_actual_id INTO v_sede_id FROM vehiculos WHERE placa = 'ABC-123';

    BEGIN
        DELETE FROM sedes WHERE id = v_sede_id;
    EXCEPTION WHEN foreign_key_violation THEN
        v_delete_prevented := TRUE;
    END;

    IF NOT v_delete_prevented THEN
        RAISE EXCEPTION 'Fallo: Se permitió eliminar una sucursal con vehículos asociados';
    END IF;

    RAISE NOTICE 'TEST 3.2 APROBADO: Protección contra huérfanos Sucursal -> Vehículo activa';
END $$;


\echo '===================================================================='
\echo '=== TEST 4: Criterio 3 - Estado Operativo vs Disponibilidad ========'
\echo '===================================================================='

-- Registrar un vehículo de prueba para manipular estados
INSERT INTO vehiculos (
    placa, vin, marca_id, categoria_id, transmision_id, combustible_id,
    estado_id, sede_actual_id, modelo, anio, color, capacidad_pasajeros,
    tarifa_diaria, disponible, activo
)
SELECT 
    'TST-005',
    '935TEST0000000005',
    (SELECT id FROM marcas WHERE nombre ILIKE '%Toyota%' LIMIT 1),
    (SELECT id FROM categorias_vehiculo WHERE codigo = 'SUV' LIMIT 1),
    (SELECT id FROM tipos_transmision WHERE codigo = 'AUTOMATICA' OR nombre ILIKE '%Automat%' LIMIT 1),
    (SELECT id FROM tipos_combustible WHERE codigo = 'GASOLINA' OR nombre ILIKE '%Gasolina%' LIMIT 1),
    (SELECT id FROM estados_vehiculo WHERE codigo = 'DISPONIBLE' LIMIT 1),
    (SELECT id FROM sedes WHERE nombre ILIKE '%Bogot%' LIMIT 1),
    'Toyota RAV4 Test Hub',
    2024,
    'Gris Plata',
    5,
    110000,
    TRUE,
    TRUE
ON CONFLICT (placa) DO UPDATE SET disponible = TRUE;

-- Registrar un bloqueo de calendario por mantenimiento
INSERT INTO disponibilidad_vehiculo (
    vehiculo_id, fecha_inicio, fecha_fin, tipo_bloqueo, motivo
)
SELECT 
    id,
    '2026-09-10 08:00:00+00'::timestamptz,
    '2026-09-15 18:00:00+00'::timestamptz,
    'MANTENIMIENTO',
    'Revisión preventiva de 10.000 KM'
FROM vehiculos WHERE placa = 'TST-005';

-- Validar consulta de traslape de disponibilidad
DO $$
DECLARE
    v_bloqueos_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_bloqueos_count
    FROM disponibilidad_vehiculo d
    JOIN vehiculos v ON d.vehiculo_id = v.id
    WHERE v.placa = 'TST-005'
      AND d.fecha_inicio <= '2026-09-12 12:00:00+00'::timestamptz
      AND d.fecha_fin >= '2026-09-12 12:00:00+00'::timestamptz;

    IF v_bloqueos_count = 0 THEN
        RAISE EXCEPTION 'Fallo: La consulta de disponibilidad por fechas no detectó el bloqueo activo';
    END IF;

    RAISE NOTICE 'TEST 4 APROBADO: Separación entre estado operativo y disponibilidad por calendario validada';
END $$;


\echo '===================================================================='
\echo '=== TEST 5: Criterio 4 - Validación de Índices de Búsqueda ========='
\echo '===================================================================='

DO $$
DECLARE
    v_missing_indexes TEXT[];
BEGIN
    SELECT ARRAY_AGG(idx_expected)
    INTO v_missing_indexes
    FROM (
        SELECT unnest(ARRAY[
            'idx_vehiculos_placa',
            'idx_vehiculos_vin',
            'idx_vehiculos_categoria_id',
            'idx_vehiculos_sede_actual_id',
            'idx_vehiculos_marca_id',
            'idx_vehiculos_estado_id',
            'idx_vehiculos_disponible',
            'idx_vehiculos_activo',
            'idx_vehiculos_destacado',
            'idx_vehiculos_catalogo_busqueda',
            'idx_vehiculo_caracteristicas_veh',
            'idx_vehiculo_caracteristicas_car',
            'idx_imagenes_vehiculo_veh_ord',
            'idx_disponibilidad_vehiculo_rango'
        ]) AS idx_expected
    ) expected
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_indexes WHERE indexname = idx_expected
    );

    IF v_missing_indexes IS NOT NULL AND array_length(v_missing_indexes, 1) > 0 THEN
        RAISE EXCEPTION 'Fallo: Índices faltantes: %', array_to_string(v_missing_indexes, ', ');
    END IF;

    RAISE NOTICE 'TEST 5 APROBADO: Todos los índices de catálogo, sucursal, estado y búsqueda existen';
END $$;


\echo '===================================================================='
\echo '=== TEST 6: Consultas de Catálogo Consolidado ======================'
\echo '===================================================================='

-- Consulta a través de la vista de catálogo
SELECT 
    placa,
    modelo,
    marca,
    categoria,
    transmision,
    combustible,
    sede_nombre,
    ciudad_nombre,
    tarifa_diaria,
    calificacion,
    destacado,
    disponible_reserva
FROM catalogo_vehiculos
WHERE ciudad_nombre = 'Bogotá' AND disponible_reserva = TRUE
ORDER BY destacado DESC, tarifa_diaria ASC;

-- Limpieza del vehículo de prueba
DELETE FROM disponibilidad_vehiculo WHERE vehiculo_id IN (SELECT id FROM vehiculos WHERE placa = 'TST-005');
DELETE FROM vehiculos WHERE placa = 'TST-005';

\echo '===================================================================='
\echo '=== TODAS LAS PRUEBAS DE HU-BD-05 COMPLETADAS EXITOSAMENTE (6/6) ==='
\echo '===================================================================='
