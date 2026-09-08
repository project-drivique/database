-- ==============================================================================
-- Drivique - Suite de Pruebas Automatizadas: HU-BD-06 Tarifas, Protecciones y Servicios
-- ==============================================================================

\echo '===================================================================='
\echo '=== TEST 1: Verificación de Persistencia Inicial DML ==============='
\echo '===================================================================='

SELECT 
    (SELECT COUNT(*) FROM coberturas_seguro) AS total_coberturas,
    (SELECT COUNT(*) FROM planes_kilometraje) AS total_planes_km,
    (SELECT COUNT(*) FROM servicios_adicionales) AS total_servicios_adicionales,
    (SELECT COUNT(*) FROM tarifas_categoria) AS total_tarifas_categoria,
    (SELECT COUNT(*) FROM vehiculo_coberturas_seguro) AS total_vehiculo_coberturas,
    (SELECT COUNT(*) FROM vehiculo_planes_kilometraje) AS total_vehiculo_planes_km,
    (SELECT COUNT(*) FROM vehiculo_servicios_adicionales) AS total_vehiculo_servicios;

DO $$
DECLARE
    v_coberturas INTEGER;
    v_planes INTEGER;
    v_servicios INTEGER;
    v_tarifas_cat INTEGER;
    v_veh_cob INTEGER;
    v_veh_plan INTEGER;
    v_veh_serv INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_coberturas FROM coberturas_seguro;
    SELECT COUNT(*) INTO v_planes FROM planes_kilometraje;
    SELECT COUNT(*) INTO v_servicios FROM servicios_adicionales;
    SELECT COUNT(*) INTO v_tarifas_cat FROM tarifas_categoria;
    SELECT COUNT(*) INTO v_veh_cob FROM vehiculo_coberturas_seguro;
    SELECT COUNT(*) INTO v_veh_plan FROM vehiculo_planes_kilometraje;
    SELECT COUNT(*) INTO v_veh_serv FROM vehiculo_servicios_adicionales;

    IF v_coberturas < 3 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 3 coberturas de seguro, encontradas: %', v_coberturas;
    END IF;

    IF v_planes < 2 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 2 planes de kilometraje, encontrados: %', v_planes;
    END IF;

    IF v_servicios < 7 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 7 servicios adicionales, encontrados: %', v_servicios;
    END IF;

    IF v_tarifas_cat < 7 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 7 tarifas vigentes por categoría, encontradas: %', v_tarifas_cat;
    END IF;

    IF v_veh_cob < 27 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 27 asignaciones vehículo-cobertura (9 vehiculos * 3), encontradas: %', v_veh_cob;
    END IF;

    IF v_veh_plan < 18 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 18 asignaciones vehículo-plan (9 vehiculos * 2), encontradas: %', v_veh_plan;
    END IF;

    IF v_veh_serv < 63 THEN
        RAISE EXCEPTION 'Fallo: Se esperaban al menos 63 asignaciones vehículo-servicio (9 vehiculos * 7), encontradas: %', v_veh_serv;
    END IF;

    RAISE NOTICE 'TEST 1 APROBADO: Tablas y relaciones de tarifas y servicios persistidas correctamente.';
END $$;


\echo '===================================================================='
\echo '=== TEST 2: Criterio 1 - Reglas de Vigencia y Moneda ==============='
\echo '===================================================================='

-- 2.1 Validar fecha_fin < fecha_inicio en tarifas_categoria (Debe fallar)
DO $$
DECLARE
    v_vigencia_failed BOOLEAN := FALSE;
    v_cat_id UUID;
BEGIN
    SELECT id INTO v_cat_id FROM categorias_vehiculo LIMIT 1;

    BEGIN
        INSERT INTO tarifas_categoria (
            categoria_id, temporada, tarifa_base_diaria, deposito_garantia,
            suplemento_km_ilimitado_diario, km_incluidos_dia, tarifa_km_excedente,
            fecha_inicio, fecha_fin, moneda
        )
        VALUES (
            v_cat_id, 'PROMOCIONAL', 100000, 500000, 20000, 200, 800,
            '2026-12-31', '2026-01-01', 'COP' -- fecha_fin anterior a fecha_inicio
        );
    EXCEPTION WHEN check_violation THEN
        v_vigencia_failed := TRUE;
    END;

    IF NOT v_vigencia_failed THEN
        RAISE EXCEPTION 'Fallo: La restricción CHECK en tarifas_categoria no rechazó fecha_fin < fecha_inicio';
    END IF;

    RAISE NOTICE 'TEST 2.1 APROBADO: Restricción de vigencia temporal en tarifas_categoria validada';
END $$;

-- 2.2 Validar fecha_fin < fecha_inicio en coberturas_seguro (Debe fallar)
DO $$
DECLARE
    v_vigencia_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO coberturas_seguro (
            codigo, nombre, descripcion, tarifa_diaria, deducible_porcentaje,
            fecha_inicio, fecha_fin
        )
        VALUES (
            'SEG_INV', 'Seguro Invalido', 'Test vigencia invalida', 50000, 10.00,
            '2026-06-01', '2026-05-01'
        );
    EXCEPTION WHEN check_violation THEN
        v_vigencia_failed := TRUE;
    END;

    IF NOT v_vigencia_failed THEN
        RAISE EXCEPTION 'Fallo: La restricción CHECK en coberturas_seguro no rechazó fecha_fin < fecha_inicio';
    END IF;

    RAISE NOTICE 'TEST 2.2 APROBADO: Restricción de vigencia temporal en coberturas_seguro validada';
END $$;

-- 2.3 Validar moneda estándar por defecto COP en tarifas_categoria
DO $$
DECLARE
    v_cat_id UUID;
    v_moneda CHAR(3);
BEGIN
    SELECT id INTO v_cat_id FROM categorias_vehiculo LIMIT 1;

    INSERT INTO tarifas_categoria (
        categoria_id, temporada, tarifa_base_diaria, fecha_inicio
    )
    VALUES (
        v_cat_id, 'PROMOCIONAL', 120000, '2027-01-01 00:00:00+00'
    )
    RETURNING moneda INTO v_moneda;

    IF v_moneda <> 'COP' THEN
        RAISE EXCEPTION 'Fallo: El valor por defecto de moneda no fue COP, fue %', v_moneda;
    END IF;

    -- Limpiar registro de prueba
    DELETE FROM tarifas_categoria WHERE temporada = 'PROMOCIONAL' AND fecha_inicio = '2027-01-01 00:00:00+00';

    RAISE NOTICE 'TEST 2.3 APROBADO: Moneda estándar COP por defecto validada exitosamente';
END $$;


\echo '===================================================================='
\echo '=== TEST 3: Criterio 2 - Versionamiento y Estados =================='
\echo '===================================================================='

-- 3.1 Unicidad de código en coberturas_seguro (Debe fallar con código existente)
DO $$
DECLARE
    v_codigo_dup_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO coberturas_seguro (codigo, nombre, tarifa_diaria)
        VALUES ('PROT_OBLIGATORIA', 'Duplicado Obligatorio', 30000);
    EXCEPTION WHEN unique_violation THEN
        v_codigo_dup_failed := TRUE;
    END;

    IF NOT v_codigo_dup_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió duplicar el código de cobertura de seguro';
    END IF;

    RAISE NOTICE 'TEST 3.1 APROBADO: Unicidad de código en coberturas_seguro validada';
END $$;

-- 3.2 Unicidad de código en planes_kilometraje (Debe fallar con código existente)
DO $$
DECLARE
    v_codigo_dup_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO planes_kilometraje (codigo, nombre, tarifa_diaria)
        VALUES ('KM_ILIMITADO', 'Duplicado KM Ilimitado', 40000);
    EXCEPTION WHEN unique_violation THEN
        v_codigo_dup_failed := TRUE;
    END;

    IF NOT v_codigo_dup_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió duplicar el código de plan de kilometraje';
    END IF;

    RAISE NOTICE 'TEST 3.2 APROBADO: Unicidad de código en planes_kilometraje validada';
END $$;

-- 3.3 Unicidad de código en servicios_adicionales (Debe fallar con código existente)
DO $$
DECLARE
    v_codigo_dup_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO servicios_adicionales (codigo, nombre, tarifa_diaria)
        VALUES ('SRV_GPS', 'Duplicado GPS', 25000);
    EXCEPTION WHEN unique_violation THEN
        v_codigo_dup_failed := TRUE;
    END;

    IF NOT v_codigo_dup_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió duplicar el código de servicio adicional';
    END IF;

    RAISE NOTICE 'TEST 3.3 APROBADO: Unicidad de código en servicios_adicionales validada';
END $$;

-- 3.4 Validar campos de versionamiento y estado activo por defecto
DO $$
DECLARE
    v_version INTEGER;
    v_activo BOOLEAN;
BEGIN
    INSERT INTO servicios_adicionales (codigo, nombre, tarifa_diaria)
    VALUES ('SRV_TEST_VER', 'Servicio Test Version', 15000)
    RETURNING version, activo INTO v_version, v_activo;

    IF v_version <> 1 OR v_activo <> TRUE THEN
        RAISE EXCEPTION 'Fallo: Valores por defecto version (%) o activo (%) incorrectos', v_version, v_activo;
    END IF;

    -- Limpiar registro de prueba
    DELETE FROM servicios_adicionales WHERE codigo = 'SRV_TEST_VER';

    RAISE NOTICE 'TEST 3.4 APROBADO: Versionamiento y estado activo por defecto validados';
END $$;


\echo '===================================================================='
\echo '=== TEST 4: Criterio 3 - Restricciones de No Negatividad ==========='
\echo '===================================================================='

-- 4.1 Tarifa diaria negativa en tarifas_categoria (Debe fallar)
DO $$
DECLARE
    v_check_failed BOOLEAN := FALSE;
    v_cat_id UUID;
BEGIN
    SELECT id INTO v_cat_id FROM categorias_vehiculo LIMIT 1;

    BEGIN
        INSERT INTO tarifas_categoria (
            categoria_id, temporada, tarifa_base_diaria, fecha_inicio
        )
        VALUES (
            v_cat_id, 'TEMPORADA_BAJA', -50000, CURRENT_DATE
        );
    EXCEPTION WHEN check_violation THEN
        v_check_failed := TRUE;
    END;

    IF NOT v_check_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió registrar tarifa_base_diaria negativa en tarifas_categoria';
    END IF;

    RAISE NOTICE 'TEST 4.1 APROBADO: Restricción tarifa >= 0 en tarifas_categoria validada';
END $$;

-- 4.2 Tarifa negativa en coberturas_seguro (Debe fallar)
DO $$
DECLARE
    v_check_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO coberturas_seguro (codigo, nombre, tarifa_diaria)
        VALUES ('SEG_NEG', 'Seguro Negativo', -10000);
    EXCEPTION WHEN check_violation THEN
        v_check_failed := TRUE;
    END;

    IF NOT v_check_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió registrar tarifa_diaria negativa en coberturas_seguro';
    END IF;

    RAISE NOTICE 'TEST 4.2 APROBADO: Restricción tarifa >= 0 en coberturas_seguro validada';
END $$;

-- 4.3 Deducible porcentaje fuera de rango (Debe fallar)
DO $$
DECLARE
    v_check_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO coberturas_seguro (codigo, nombre, tarifa_diaria, deducible_porcentaje)
        VALUES ('SEG_DED_INV', 'Seguro Deducible Invalido', 30000, 150.00);
    EXCEPTION WHEN check_violation THEN
        v_check_failed := TRUE;
    END;

    IF NOT v_check_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió registrar deducible > 100%% en coberturas_seguro';
    END IF;

    RAISE NOTICE 'TEST 4.3 APROBADO: Restricción 0 <= deducible <= 100 validada';
END $$;

-- 4.4 Tarifa diaria negativa en servicios_adicionales (Debe fallar)
DO $$
DECLARE
    v_check_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO servicios_adicionales (codigo, nombre, tarifa_diaria)
        VALUES ('SERV_NEG', 'Servicio Negativo', -20000);
    EXCEPTION WHEN check_violation THEN
        v_check_failed := TRUE;
    END;

    IF NOT v_check_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió registrar tarifa_diaria negativa en servicios_adicionales';
    END IF;

    RAISE NOTICE 'TEST 4.4 APROBADO: Restricción tarifa >= 0 en servicios_adicionales validada';
END $$;

-- 4.5 Tarifa km excedente negativa en planes_kilometraje (Debe fallar)
DO $$
DECLARE
    v_check_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO planes_kilometraje (codigo, nombre, tarifa_diaria, tarifa_km_excedente)
        VALUES ('KM_NEG', 'Plan KM Negativo', 10000, -500);
    EXCEPTION WHEN check_violation THEN
        v_check_failed := TRUE;
    END;

    IF NOT v_check_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió registrar tarifa_km_excedente negativa en planes_kilometraje';
    END IF;

    RAISE NOTICE 'TEST 4.5 APROBADO: Restricción montos >= 0 en planes_kilometraje validada';
END $$;


\echo '===================================================================='
\echo '=== TEST 5: Criterio 4 - Relaciones con Categorías y Vehículos ====='
\echo '===================================================================='

-- 5.1 FK tarifas_categoria -> categorias_vehiculo con UUID inexistente (Debe fallar)
DO $$
DECLARE
    v_fk_failed BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO tarifas_categoria (
            categoria_id, temporada, tarifa_base_diaria, fecha_inicio
        )
        VALUES (
            '00000000-0000-0000-0000-000000000000', 'TEMPORADA_ALTA', 100000, CURRENT_DATE
        );
    EXCEPTION WHEN foreign_key_violation THEN
        v_fk_failed := TRUE;
    END;

    IF NOT v_fk_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió registrar tarifa_categoria con categoria_id inexistente';
    END IF;

    RAISE NOTICE 'TEST 5.1 APROBADO: Integridad referencial FK categoria_id validada';
END $$;

-- 5.2 FK vehiculo_coberturas_seguro con vehiculo inexistente (Debe fallar)
DO $$
DECLARE
    v_fk_failed BOOLEAN := FALSE;
    v_cob_id UUID;
BEGIN
    SELECT id INTO v_cob_id FROM coberturas_seguro LIMIT 1;

    BEGIN
        INSERT INTO vehiculo_coberturas_seguro (vehiculo_id, cobertura_id, tarifa_diaria)
        VALUES ('00000000-0000-0000-0000-000000000000', v_cob_id, 29000);
    EXCEPTION WHEN foreign_key_violation THEN
        v_fk_failed := TRUE;
    END;

    IF NOT v_fk_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió asignar cobertura a vehiculo inexistente';
    END IF;

    RAISE NOTICE 'TEST 5.2 APROBADO: Integridad referencial vehiculo_coberturas_seguro validada';
END $$;

-- 5.3 FK vehiculo_planes_kilometraje con plan inexistente (Debe fallar)
DO $$
DECLARE
    v_fk_failed BOOLEAN := FALSE;
    v_veh_id UUID;
BEGIN
    SELECT id INTO v_veh_id FROM vehiculos LIMIT 1;

    BEGIN
        INSERT INTO vehiculo_planes_kilometraje (vehiculo_id, plan_kilometraje_id, tarifa_diaria, tarifa_kilometro_excedente)
        VALUES (v_veh_id, '00000000-0000-0000-0000-000000000000', 0, 800);
    EXCEPTION WHEN foreign_key_violation THEN
        v_fk_failed := TRUE;
    END;

    IF NOT v_fk_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió asignar plan inexistente a vehiculo';
    END IF;

    RAISE NOTICE 'TEST 5.3 APROBADO: Integridad referencial vehiculo_planes_kilometraje validada';
END $$;

-- 5.4 FK vehiculo_servicios_adicionales con servicio inexistente (Debe fallar)
DO $$
DECLARE
    v_fk_failed BOOLEAN := FALSE;
    v_veh_id UUID;
BEGIN
    SELECT id INTO v_veh_id FROM vehiculos LIMIT 1;

    BEGIN
        INSERT INTO vehiculo_servicios_adicionales (vehiculo_id, servicio_adicional_id, tarifa_diaria)
        VALUES (v_veh_id, '00000000-0000-0000-0000-000000000000', 15000);
    EXCEPTION WHEN foreign_key_violation THEN
        v_fk_failed := TRUE;
    END;

    IF NOT v_fk_failed THEN
        RAISE EXCEPTION 'Fallo: Se permitió asignar servicio inexistente a vehiculo';
    END IF;

    RAISE NOTICE 'TEST 5.4 APROBADO: Integridad referencial vehiculo_servicios_adicionales validada';
END $$;


\echo '===================================================================='
\echo '=== TEST 6: Vista de Catálogo Consolidado de Tarifas ==============='
\echo '===================================================================='

SELECT 
    placa,
    modelo,
    categoria,
    tarifa_base_km_limitado,
    tarifa_km_ilimitado,
    km_incluidos_dia,
    tarifa_km_excedente,
    deposito_garantia,
    jsonb_array_length(coberturas_disponibles) AS total_coberturas,
    jsonb_array_length(servicios_adicionales_disponibles) AS total_servicios
FROM tarifas_completas_vehiculo
ORDER BY placa;

DO $$
DECLARE
    v_count_vista INTEGER;
    v_sin_coberturas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count_vista FROM tarifas_completas_vehiculo;
    SELECT COUNT(*) INTO v_sin_coberturas 
    FROM tarifas_completas_vehiculo 
    WHERE coberturas_disponibles IS NULL OR jsonb_array_length(coberturas_disponibles) = 0;

    IF v_count_vista < 9 THEN
        RAISE EXCEPTION 'Fallo: La vista tarifas_completas_vehiculo arrojó % registros, esperados >= 9', v_count_vista;
    END IF;

    IF v_sin_coberturas > 0 THEN
        RAISE EXCEPTION 'Fallo: Existen % vehículos sin coberturas asignadas en la vista', v_sin_coberturas;
    END IF;

    RAISE NOTICE 'TEST 6 APROBADO: Vista consolidada de tarifas y servicios operativa y consistente.';
END $$;

\echo '===================================================================='
\echo '=== TODAS LAS PRUEBAS DE HU-BD-06 PASARON EXITOSAMENTE (6/6) ======='
\echo '===================================================================='
