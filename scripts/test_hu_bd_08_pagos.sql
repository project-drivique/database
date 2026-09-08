-- =============================================================================
-- Drivique - Pruebas de integridad HU-BD-08: pagos virtuales y efectivo
-- =============================================================================

\set ON_ERROR_STOP on
BEGIN;

DO $$
DECLARE
    v_cliente_id UUID;
    v_cajero_id UUID;
    v_vehiculo_id UUID;
    v_sede_id UUID;
    v_reserva_id UUID;
    v_contrato_id UUID;
    v_estado_reserva_id UUID;
    v_estado_contrato_id UUID;
    v_estado_pendiente_id UUID;
    v_estado_efectivo_id UUID;
    v_metodo_pse_id UUID;
    v_metodo_efectivo_id UUID;
    v_proveedor_wompi_id UUID;
    v_proveedor_efectivo_id UUID;
    v_pago_virtual_id UUID;
    v_pago_efectivo_id UUID;
    v_referencia_duplicada_rechazada BOOLEAN := FALSE;
    v_idempotencia_duplicada_rechazada BOOLEAN := FALSE;
    v_pan_rechazado BOOLEAN := FALSE;
    v_confirmacion_virtual_rechazada BOOLEAN := FALSE;
    v_historial_count INTEGER;
BEGIN
    IF to_regclass('public.proveedores_pago') IS NULL
       OR to_regclass('public.confirmaciones_efectivo') IS NULL
       OR to_regclass('public.historial_estados_pago') IS NULL THEN
        RAISE EXCEPTION 'Fallo: no se aplico la migracion V9 de pagos';
    END IF;

    SELECT id, sede_actual_id INTO v_vehiculo_id, v_sede_id
    FROM vehiculos ORDER BY created_at LIMIT 1;

    INSERT INTO usuarios (
        nombres, apellidos, email, telefono, documento_tipo, documento_numero,
        fecha_nacimiento, password_hash
    ) VALUES
        ('Cliente', 'HU BD 08', 'hu-bd-08-cliente@example.test', '3000000008', 'CC', 'HU-BD-08-CLIENTE', DATE '1990-01-01', 'hash-prueba'),
        ('Cajero', 'HU BD 08', 'hu-bd-08-cajero@example.test', '3000000009', 'CC', 'HU-BD-08-CAJERO', DATE '1991-01-01', 'hash-prueba');

    SELECT id INTO v_cliente_id FROM usuarios WHERE email = 'hu-bd-08-cliente@example.test';
    SELECT id INTO v_cajero_id FROM usuarios WHERE email = 'hu-bd-08-cajero@example.test';
    SELECT id INTO v_estado_reserva_id FROM estados_reserva WHERE codigo = 'PENDIENTE_PAGO';
    SELECT id INTO v_estado_contrato_id FROM estados_contrato WHERE codigo = 'PENDIENTE_FIRMA';
    SELECT id INTO v_estado_pendiente_id FROM estados_pago WHERE codigo = 'PENDIENTE';
    SELECT id INTO v_estado_efectivo_id FROM estados_pago WHERE codigo = 'PENDIENTE_EFECTIVO';
    SELECT id INTO v_metodo_pse_id FROM metodos_pago WHERE codigo = 'PSE';
    SELECT id INTO v_metodo_efectivo_id FROM metodos_pago WHERE codigo = 'EFECTIVO';
    SELECT id INTO v_proveedor_wompi_id FROM proveedores_pago WHERE codigo = 'WOMPI';
    SELECT id INTO v_proveedor_efectivo_id FROM proveedores_pago WHERE codigo = 'EFECTIVO';

    INSERT INTO reservas (
        codigo, cliente_id, vehiculo_id, estado_id, sede_recogida_id, sede_devolucion_id,
        fecha_recogida, fecha_devolucion, tarifa_diaria, total_estimado
    ) VALUES (
        'HU08-RES-001', v_cliente_id, v_vehiculo_id, v_estado_reserva_id, v_sede_id, v_sede_id,
        '2032-01-10 09:00:00+00', '2032-01-12 09:00:00+00', 100000, 200000
    ) RETURNING id INTO v_reserva_id;

    INSERT INTO contratos_alquiler (
        numero, reserva_id, cliente_id, vehiculo_id, estado_id, sede_recogida_id,
        sede_devolucion_id, inicio_programado_at, fin_programado_at, valor_base
    ) VALUES (
        'HU08-CON-001', v_reserva_id, v_cliente_id, v_vehiculo_id, v_estado_contrato_id,
        v_sede_id, v_sede_id, '2032-01-10 09:00:00+00', '2032-01-12 09:00:00+00', 200000
    ) RETURNING id INTO v_contrato_id;

    INSERT INTO pagos (
        contrato_id, reserva_id, metodo_pago_id, estado_id, proveedor_id, proveedor,
        referencia_externa, clave_idempotencia, token_metodo_pago, monto
    ) VALUES (
        v_contrato_id, v_reserva_id, v_metodo_pse_id, v_estado_pendiente_id, v_proveedor_wompi_id,
        'Wompi', 'WOMPI-HU08-001', 'idem-hu08-virtual-001', 'tok_wompi_abc', 200000
    ) RETURNING id INTO v_pago_virtual_id;

    BEGIN
        INSERT INTO pagos (
            contrato_id, reserva_id, metodo_pago_id, estado_id, proveedor_id,
            referencia_externa, clave_idempotencia, monto
        ) VALUES (
            v_contrato_id, v_reserva_id, v_metodo_pse_id, v_estado_pendiente_id, v_proveedor_wompi_id,
            'WOMPI-HU08-001', 'idem-hu08-virtual-002', 200000
        );
    EXCEPTION WHEN unique_violation THEN
        v_referencia_duplicada_rechazada := TRUE;
    END;

    IF NOT v_referencia_duplicada_rechazada THEN
        RAISE EXCEPTION 'Fallo: se permitio una referencia externa duplicada';
    END IF;

    BEGIN
        INSERT INTO pagos (
            contrato_id, reserva_id, metodo_pago_id, estado_id, proveedor_id,
            referencia_externa, clave_idempotencia, monto
        ) VALUES (
            v_contrato_id, v_reserva_id, v_metodo_pse_id, v_estado_pendiente_id, v_proveedor_wompi_id,
            'WOMPI-HU08-002', 'idem-hu08-virtual-001', 200000
        );
    EXCEPTION WHEN unique_violation THEN
        v_idempotencia_duplicada_rechazada := TRUE;
    END;

    IF NOT v_idempotencia_duplicada_rechazada THEN
        RAISE EXCEPTION 'Fallo: se permitio una clave de idempotencia duplicada';
    END IF;

    BEGIN
        INSERT INTO pagos (
            contrato_id, reserva_id, metodo_pago_id, estado_id, proveedor_id,
            referencia_externa, clave_idempotencia, token_metodo_pago, monto
        ) VALUES (
            v_contrato_id, v_reserva_id, v_metodo_pse_id, v_estado_pendiente_id, v_proveedor_wompi_id,
            'WOMPI-HU08-003', 'idem-hu08-pan-001', '4111111111111111', 200000
        );
    EXCEPTION WHEN check_violation THEN
        v_pan_rechazado := TRUE;
    END;

    IF NOT v_pan_rechazado THEN
        RAISE EXCEPTION 'Fallo: se permitio persistir un numero completo de tarjeta';
    END IF;

    INSERT INTO pagos (
        contrato_id, reserva_id, metodo_pago_id, estado_id, proveedor_id, proveedor,
        referencia_externa, clave_idempotencia, monto
    ) VALUES (
        v_contrato_id, v_reserva_id, v_metodo_efectivo_id, v_estado_efectivo_id, v_proveedor_efectivo_id,
        'Caja de sucursal', 'CAJA-HU08-001', 'idem-hu08-efectivo-001', 200000
    ) RETURNING id INTO v_pago_efectivo_id;

    BEGIN
        INSERT INTO confirmaciones_efectivo (pago_id, confirmado_por, referencia_caja)
        VALUES (v_pago_virtual_id, v_cajero_id, 'CAJA-HU08-VIRTUAL');
    EXCEPTION WHEN check_violation THEN
        v_confirmacion_virtual_rechazada := TRUE;
    END;

    IF NOT v_confirmacion_virtual_rechazada THEN
        RAISE EXCEPTION 'Fallo: se confirmo en caja un pago virtual';
    END IF;

    INSERT INTO confirmaciones_efectivo (
        pago_id, confirmado_por, referencia_caja, evidencia_url, observaciones
    ) VALUES (
        v_pago_efectivo_id, v_cajero_id, 'CAJA-HU08-EFECTIVO',
        'https://evidencias.drivique.test/pagos/CAJA-HU08-EFECTIVO.pdf', 'Efectivo recibido en sucursal'
    );

    IF NOT EXISTS (
        SELECT 1 FROM pagos p
        JOIN estados_pago e ON e.id = p.estado_id
        WHERE p.id = v_pago_efectivo_id
          AND e.codigo = 'CONFIRMADO_EFECTIVO'
          AND p.confirmado_por = v_cajero_id
    ) THEN
        RAISE EXCEPTION 'Fallo: la confirmacion de efectivo no actualizo el pago';
    END IF;

    SELECT COUNT(*) INTO v_historial_count
    FROM historial_estados_pago
    WHERE pago_id = v_pago_efectivo_id;

    IF v_historial_count <> 2 THEN
        RAISE EXCEPTION 'Fallo: el historial de efectivo debe tener 2 eventos y tiene %', v_historial_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public' AND indexname = 'uq_pagos_proveedor_idempotencia'
    ) THEN
        RAISE EXCEPTION 'Fallo: falta el indice de idempotencia';
    END IF;

    RAISE NOTICE 'HU-BD-08 APROBADA: pagos, idempotencia, efectivo y seguridad de tarjeta validados.';
END;
$$;

ROLLBACK;
