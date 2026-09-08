-- =============================================================================
-- Drivique - Pruebas de integridad HU-BD-09: contratos, versiones y firmas
-- =============================================================================

\set ON_ERROR_STOP on
BEGIN;

DO $$
DECLARE
    v_cliente_id UUID;
    v_vehiculo_id UUID;
    v_sede_id UUID;
    v_reserva_id UUID;
    v_reserva_alterna_id UUID;
    v_estado_reserva_id UUID;
    v_estado_contrato_id UUID;
    v_contrato_id UUID;
    v_version_id UUID;
    v_version_sin_firma_id UUID;
    v_vinculo_rechazado BOOLEAN := FALSE;
    v_duplicado_rechazado BOOLEAN := FALSE;
    v_version_inmutable BOOLEAN := FALSE;
    v_firma_sin_evidencia_rechazada BOOLEAN := FALSE;
BEGIN
    IF to_regclass('public.contrato_versiones') IS NULL
       OR to_regclass('public.firmas_contrato') IS NULL THEN
        RAISE EXCEPTION 'Fallo: no se aplico la migracion V8 de contratos';
    END IF;

    SELECT id, sede_actual_id INTO v_vehiculo_id, v_sede_id
    FROM vehiculos
    ORDER BY created_at
    LIMIT 1;

    INSERT INTO usuarios (
        nombres, apellidos, email, telefono, documento_tipo, documento_numero,
        fecha_nacimiento, password_hash
    )
    VALUES (
        'Prueba', 'HU BD 09', 'hu-bd-09@example.test', '3000000001', 'CC',
        'HU-BD-09-TEST', DATE '1990-01-01', 'hash-de-prueba'
    )
    RETURNING id INTO v_cliente_id;

    SELECT id INTO v_estado_reserva_id FROM estados_reserva WHERE codigo = 'PENDIENTE_PAGO';
    SELECT id INTO v_estado_contrato_id FROM estados_contrato WHERE codigo = 'PENDIENTE_FIRMA';

    INSERT INTO reservas (
        codigo, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
        sede_devolucion_id, fecha_recogida, fecha_devolucion, tarifa_diaria,
        total_estimado
    )
    VALUES (
        'HU09-RES-001', v_cliente_id, v_vehiculo_id, v_estado_reserva_id, v_sede_id,
        v_sede_id, '2031-01-10 09:00:00+00', '2031-01-12 09:00:00+00', 100000, 200000
    )
    RETURNING id INTO v_reserva_id;

    INSERT INTO reservas (
        codigo, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
        sede_devolucion_id, fecha_recogida, fecha_devolucion, tarifa_diaria,
        total_estimado
    )
    VALUES (
        'HU09-RES-002', v_cliente_id, v_vehiculo_id, v_estado_reserva_id, v_sede_id,
        v_sede_id, '2031-02-10 09:00:00+00', '2031-02-12 09:00:00+00', 100000, 200000
    )
    RETURNING id INTO v_reserva_alterna_id;

    INSERT INTO contratos_alquiler (
        numero, reserva_id, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
        sede_devolucion_id, inicio_programado_at, fin_programado_at, valor_base
    )
    VALUES (
        'HU09-CON-001', v_reserva_id, v_cliente_id, v_vehiculo_id, v_estado_contrato_id,
        v_sede_id, v_sede_id, '2031-01-10 09:00:00+00', '2031-01-12 09:00:00+00', 200000
    )
    RETURNING id INTO v_contrato_id;

    INSERT INTO contrato_versiones (
        contrato_id, numero_version, documento_url, documento_hash, creado_por
    )
    VALUES (
        v_contrato_id, 1, 'https://evidencias.drivique.test/contratos/HU09-CON-001-v1.pdf',
        repeat('a', 64), v_cliente_id
    )
    RETURNING id INTO v_version_id;

    INSERT INTO firmas_contrato (
        contrato_version_id, firmante_id, tipo_firma, evidencia_url, evidencia_hash,
        ip_origen, user_agent
    )
    VALUES (
        v_version_id, v_cliente_id, 'ELECTRONICA',
        'https://evidencias.drivique.test/firmas/HU09-CON-001-v1.json', repeat('b', 64),
        '127.0.0.1', 'HU-BD-09 test'
    );

    BEGIN
        UPDATE contratos_alquiler
        SET reserva_id = v_reserva_alterna_id
        WHERE id = v_contrato_id;
    EXCEPTION WHEN check_violation THEN
        v_vinculo_rechazado := TRUE;
    END;

    IF NOT v_vinculo_rechazado THEN
        RAISE EXCEPTION 'Fallo: se permitio cambiar la reserva de un contrato';
    END IF;

    BEGIN
        INSERT INTO contratos_alquiler (
            numero, reserva_id, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
            sede_devolucion_id, inicio_programado_at, fin_programado_at, valor_base
        )
        VALUES (
            'HU09-CON-002', v_reserva_id, v_cliente_id, v_vehiculo_id, v_estado_contrato_id,
            v_sede_id, v_sede_id, '2031-01-10 09:00:00+00', '2031-01-12 09:00:00+00', 200000
        );
    EXCEPTION WHEN unique_violation THEN
        v_duplicado_rechazado := TRUE;
    END;

    IF NOT v_duplicado_rechazado THEN
        RAISE EXCEPTION 'Fallo: se permitieron multiples contratos para la misma reserva';
    END IF;

    BEGIN
        UPDATE contrato_versiones
        SET documento_url = 'https://evidencias.drivique.test/contratos/modificado.pdf'
        WHERE id = v_version_id;
    EXCEPTION WHEN check_violation THEN
        v_version_inmutable := TRUE;
    END;

    IF NOT v_version_inmutable THEN
        RAISE EXCEPTION 'Fallo: se permitio modificar una version de contrato';
    END IF;

    INSERT INTO contrato_versiones (
        contrato_id, numero_version, documento_url, documento_hash, creado_por
    )
    VALUES (
        v_contrato_id, 2, 'https://evidencias.drivique.test/contratos/HU09-CON-001-v2.pdf',
        repeat('c', 64), v_cliente_id
    )
    RETURNING id INTO v_version_sin_firma_id;

    BEGIN
        INSERT INTO firmas_contrato (
            contrato_version_id, firmante_id, tipo_firma, evidencia_hash
        )
        VALUES (v_version_sin_firma_id, v_cliente_id, 'TRAZO', repeat('d', 64));
    EXCEPTION WHEN check_violation THEN
        v_firma_sin_evidencia_rechazada := TRUE;
    END;

    IF NOT v_firma_sin_evidencia_rechazada THEN
        RAISE EXCEPTION 'Fallo: se permitio una firma sin evidencia';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public' AND indexname = 'idx_contratos_cliente_fecha'
    ) THEN
        RAISE EXCEPTION 'Fallo: falta el indice de consulta por cliente';
    END IF;

    RAISE NOTICE 'HU-BD-09 APROBADA: contrato inmutable, versiones, firmas e indices validados.';
END;
$$;

ROLLBACK;
