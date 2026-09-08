-- =============================================================================
-- Drivique - Pruebas de integridad HU-BD-07: reservas y maquina de estados
-- Ejecutar despues de aplicar las migraciones Flyway.
-- La transaccion se revierte para no dejar datos manuales de prueba.
-- =============================================================================

\set ON_ERROR_STOP on
BEGIN;

DO $$
DECLARE
    v_cliente_id UUID;
    v_vehiculo_id UUID;
    v_sede_id UUID;
    v_pendiente_id UUID;
    v_confirmada_id UUID;
    v_completada_id UUID;
    v_cancelada_id UUID;
    v_solapamiento_rechazado BOOLEAN := FALSE;
    v_transicion_rechazada BOOLEAN := FALSE;
    v_sucursal_rechazada BOOLEAN := FALSE;
    v_historial_count INTEGER;
BEGIN
    IF to_regclass('public.transiciones_estado_reserva') IS NULL
       OR to_regclass('public.historial_estados_reserva') IS NULL THEN
        RAISE EXCEPTION 'Fallo: no se aplico la migracion V7 de reservas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'reservas_vehiculo_periodo_sin_solapamiento'
    ) THEN
        RAISE EXCEPTION 'Fallo: falta la restriccion de solapamientos';
    END IF;

    SELECT id INTO v_vehiculo_id FROM vehiculos ORDER BY created_at LIMIT 1;
    SELECT sede_actual_id INTO v_sede_id FROM vehiculos WHERE id = v_vehiculo_id;

    IF v_vehiculo_id IS NULL OR v_sede_id IS NULL THEN
        RAISE EXCEPTION 'Fallo: se requiere un vehiculo con sucursal para ejecutar la prueba';
    END IF;

    INSERT INTO usuarios (
        nombres, apellidos, email, telefono, documento_tipo, documento_numero,
        fecha_nacimiento, password_hash
    )
    VALUES (
        'Prueba', 'HU BD 07', 'hu-bd-07@example.test', '3000000000', 'CC',
        'HU-BD-07-TEST', DATE '1990-01-01', 'hash-de-prueba'
    )
    RETURNING id INTO v_cliente_id;

    SELECT id INTO v_pendiente_id FROM estados_reserva WHERE codigo = 'PENDIENTE_PAGO';
    SELECT id INTO v_confirmada_id FROM estados_reserva WHERE codigo = 'CONFIRMADA';
    SELECT id INTO v_completada_id FROM estados_reserva WHERE codigo = 'COMPLETADA';
    SELECT id INTO v_cancelada_id FROM estados_reserva WHERE codigo = 'CANCELADA';

    INSERT INTO reservas (
        codigo, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
        sede_devolucion_id, fecha_recogida, fecha_devolucion, tarifa_diaria,
        total_estimado
    )
    VALUES (
        'HU07-RES-001', v_cliente_id, v_vehiculo_id, v_pendiente_id, v_sede_id,
        v_sede_id, '2030-01-10 09:00:00+00', '2030-01-12 09:00:00+00', 100000, 200000
    );

    BEGIN
        INSERT INTO reservas (
            codigo, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
            sede_devolucion_id, fecha_recogida, fecha_devolucion, tarifa_diaria,
            total_estimado
        )
        VALUES (
            'HU07-RES-002', v_cliente_id, v_vehiculo_id, v_pendiente_id, v_sede_id,
            v_sede_id, '2030-01-11 09:00:00+00', '2030-01-13 09:00:00+00', 100000, 200000
        );
    EXCEPTION WHEN exclusion_violation THEN
        v_solapamiento_rechazado := TRUE;
    END;

    IF NOT v_solapamiento_rechazado THEN
        RAISE EXCEPTION 'Fallo: se permitio una reserva solapada para el mismo vehiculo';
    END IF;

    UPDATE reservas
    SET estado_id = v_confirmada_id
    WHERE codigo = 'HU07-RES-001';

    BEGIN
        UPDATE reservas
        SET estado_id = v_completada_id
        WHERE codigo = 'HU07-RES-001';
    EXCEPTION WHEN check_violation THEN
        v_transicion_rechazada := TRUE;
    END;

    IF NOT v_transicion_rechazada THEN
        RAISE EXCEPTION 'Fallo: se permitio una transicion CONFIRMADA -> COMPLETADA';
    END IF;

    UPDATE reservas
    SET estado_id = v_cancelada_id
    WHERE codigo = 'HU07-RES-001';

    INSERT INTO reservas (
        codigo, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
        sede_devolucion_id, fecha_recogida, fecha_devolucion, tarifa_diaria,
        total_estimado
    )
    VALUES (
        'HU07-RES-003', v_cliente_id, v_vehiculo_id, v_pendiente_id, v_sede_id,
        v_sede_id, '2030-01-11 09:00:00+00', '2030-01-13 09:00:00+00', 100000, 200000
    );

    BEGIN
        INSERT INTO reservas (
            codigo, cliente_id, vehiculo_id, estado_id, fecha_recogida,
            fecha_devolucion, tarifa_diaria, total_estimado
        )
        VALUES (
            'HU07-RES-004', v_cliente_id, v_vehiculo_id, v_pendiente_id,
            '2030-02-10 09:00:00+00', '2030-02-12 09:00:00+00', 100000, 200000
        );
    EXCEPTION WHEN check_violation THEN
        v_sucursal_rechazada := TRUE;
    END;

    IF NOT v_sucursal_rechazada THEN
        RAISE EXCEPTION 'Fallo: se permitio una reserva sin sucursales';
    END IF;

    SELECT COUNT(*) INTO v_historial_count
    FROM historial_estados_reserva h
    JOIN reservas r ON r.id = h.reserva_id
    WHERE r.codigo = 'HU07-RES-001';

    IF v_historial_count <> 3 THEN
        RAISE EXCEPTION 'Fallo: historial de estados incompleto; se esperaban 3 eventos y se obtuvieron %', v_historial_count;
    END IF;

    RAISE NOTICE 'HU-BD-07 APROBADA: relaciones, solapamientos, transiciones e historial validados.';
END;
$$;

ROLLBACK;
