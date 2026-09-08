-- =============================================================================
-- Flyway Migration: V9__pagos_virtuales_y_efectivo.sql
-- Historia: HU-BD-08 - Persistir pagos virtuales y en efectivo
-- =============================================================================

CREATE TABLE IF NOT EXISTS proveedores_pago (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('PASARELA', 'EFECTIVO')),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE metodos_pago
    ADD COLUMN IF NOT EXISTS tipo VARCHAR(20) NOT NULL DEFAULT 'VIRTUAL'
        CHECK (tipo IN ('VIRTUAL', 'EFECTIVO')),
    ADD COLUMN IF NOT EXISTS requiere_confirmacion_manual BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO proveedores_pago (codigo, nombre, tipo)
VALUES
    ('WOMPI', 'Wompi', 'PASARELA'),
    ('MERCADO_PAGO', 'Mercado Pago', 'PASARELA'),
    ('EFECTIVO', 'Caja de sucursal', 'EFECTIVO'),
    ('LEGACY', 'Proveedor legado', 'PASARELA')
ON CONFLICT (codigo) DO UPDATE
SET nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    activo = TRUE;

INSERT INTO metodos_pago (codigo, nombre, tipo, requiere_confirmacion_manual)
VALUES
    ('TARJETA', 'Tarjeta tokenizada', 'VIRTUAL', FALSE),
    ('PSE', 'PSE', 'VIRTUAL', FALSE),
    ('EFECTIVO', 'Efectivo en sucursal', 'EFECTIVO', TRUE)
ON CONFLICT (codigo) DO UPDATE
SET nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    requiere_confirmacion_manual = EXCLUDED.requiere_confirmacion_manual,
    activo = TRUE;

INSERT INTO estados_pago (codigo, nombre, es_final)
VALUES
    ('PENDIENTE', 'Pendiente de confirmacion virtual', FALSE),
    ('PENDIENTE_EFECTIVO', 'Pendiente de confirmacion en efectivo', FALSE),
    ('APROBADO', 'Pago virtual aprobado', TRUE),
    ('CONFIRMADO_EFECTIVO', 'Pago en efectivo confirmado', TRUE),
    ('RECHAZADO', 'Pago rechazado', TRUE),
    ('CANCELADO', 'Pago cancelado', TRUE)
ON CONFLICT (codigo) DO UPDATE
SET nombre = EXCLUDED.nombre,
    es_final = EXCLUDED.es_final;

ALTER TABLE pagos
    ADD COLUMN IF NOT EXISTS reserva_id UUID REFERENCES reservas(id),
    ADD COLUMN IF NOT EXISTS proveedor_id UUID REFERENCES proveedores_pago(id),
    ADD COLUMN IF NOT EXISTS clave_idempotencia VARCHAR(100) NOT NULL DEFAULT gen_random_uuid()::text;

-- Los pagos legados se enlazan a la reserva de su contrato.
UPDATE pagos p
SET reserva_id = c.reserva_id
FROM contratos_alquiler c
WHERE c.id = p.contrato_id
  AND p.reserva_id IS NULL;

UPDATE pagos p
SET proveedor_id = pr.id
FROM proveedores_pago pr
WHERE p.proveedor_id IS NULL
  AND pr.codigo = 'LEGACY';

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pagos WHERE reserva_id IS NULL) THEN
        RAISE EXCEPTION 'No se puede aplicar V9: existen pagos sin reserva asociada';
    END IF;
END;
$$;

ALTER TABLE pagos
    ALTER COLUMN reserva_id SET NOT NULL,
    ALTER COLUMN proveedor_id SET NOT NULL,
    ADD CONSTRAINT chk_pagos_clave_idempotencia_no_vacia
        CHECK (length(trim(clave_idempotencia)) > 0);

CREATE TABLE IF NOT EXISTS historial_estados_pago (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pago_id UUID NOT NULL REFERENCES pagos(id) ON DELETE CASCADE,
    estado_anterior_id UUID REFERENCES estados_pago(id),
    estado_nuevo_id UUID NOT NULL REFERENCES estados_pago(id),
    registrado_por UUID REFERENCES usuarios(id),
    fuente VARCHAR(30) NOT NULL DEFAULT 'SISTEMA'
        CHECK (fuente IN ('SISTEMA', 'PASARELA', 'CAJA', 'ADMIN')),
    detalle VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS confirmaciones_efectivo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pago_id UUID NOT NULL UNIQUE REFERENCES pagos(id) ON DELETE RESTRICT,
    confirmado_por UUID NOT NULL REFERENCES usuarios(id),
    confirmado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    referencia_caja VARCHAR(100) NOT NULL UNIQUE,
    evidencia_url VARCHAR(1000),
    observaciones VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION validar_pago_reserva_y_token()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_reserva_id UUID;
BEGIN
    SELECT reserva_id INTO v_reserva_id
    FROM contratos_alquiler
    WHERE id = NEW.contrato_id;

    IF NOT FOUND OR NEW.reserva_id IS DISTINCT FROM v_reserva_id THEN
        RAISE EXCEPTION 'El pago debe estar vinculado a la misma reserva de su contrato'
            USING ERRCODE = '23514';
    END IF;

    -- Un token nunca debe contener un numero completo de tarjeta (PAN).
    IF NEW.token_metodo_pago IS NOT NULL
       AND NEW.token_metodo_pago ~ '[0-9]{13,19}' THEN
        RAISE EXCEPTION 'No se permite persistir un numero completo de tarjeta'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION validar_token_metodo_guardado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.token ~ '[0-9]{13,19}' THEN
        RAISE EXCEPTION 'No se permite persistir un numero completo de tarjeta'
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION registrar_historial_estado_pago()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' OR NEW.estado_id IS DISTINCT FROM OLD.estado_id THEN
        INSERT INTO historial_estados_pago (
            pago_id, estado_anterior_id, estado_nuevo_id, registrado_por, fuente
        )
        VALUES (
            NEW.id,
            CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE OLD.estado_id END,
            NEW.estado_id,
            NEW.confirmado_por,
            CASE WHEN NEW.confirmado_por IS NULL THEN 'SISTEMA' ELSE 'CAJA' END
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION confirmar_pago_efectivo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo_metodo VARCHAR(20);
    v_estado_confirmado_id UUID;
BEGIN
    SELECT mp.tipo INTO v_tipo_metodo
    FROM pagos p
    JOIN metodos_pago mp ON mp.id = p.metodo_pago_id
    WHERE p.id = NEW.pago_id;

    IF v_tipo_metodo IS DISTINCT FROM 'EFECTIVO' THEN
        RAISE EXCEPTION 'Solo los pagos en efectivo admiten confirmacion de caja'
            USING ERRCODE = '23514';
    END IF;

    SELECT id INTO v_estado_confirmado_id
    FROM estados_pago
    WHERE codigo = 'CONFIRMADO_EFECTIVO';

    UPDATE pagos
    SET estado_id = v_estado_confirmado_id,
        pagado_at = NEW.confirmado_at,
        confirmado_por = NEW.confirmado_por,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.pago_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_pago_reserva_y_token ON pagos;
CREATE TRIGGER trg_validar_pago_reserva_y_token
BEFORE INSERT OR UPDATE OF contrato_id, reserva_id, token_metodo_pago ON pagos
FOR EACH ROW
EXECUTE FUNCTION validar_pago_reserva_y_token();

DROP TRIGGER IF EXISTS trg_validar_token_metodo_guardado ON metodos_pago_guardados;
CREATE TRIGGER trg_validar_token_metodo_guardado
BEFORE INSERT OR UPDATE OF token ON metodos_pago_guardados
FOR EACH ROW
EXECUTE FUNCTION validar_token_metodo_guardado();

DROP TRIGGER IF EXISTS trg_registrar_historial_estado_pago ON pagos;
CREATE TRIGGER trg_registrar_historial_estado_pago
AFTER INSERT OR UPDATE OF estado_id ON pagos
FOR EACH ROW
EXECUTE FUNCTION registrar_historial_estado_pago();

DROP TRIGGER IF EXISTS trg_confirmar_pago_efectivo ON confirmaciones_efectivo;
CREATE TRIGGER trg_confirmar_pago_efectivo
AFTER INSERT ON confirmaciones_efectivo
FOR EACH ROW
EXECUTE FUNCTION confirmar_pago_efectivo();

CREATE UNIQUE INDEX IF NOT EXISTS uq_pagos_proveedor_referencia_externa
    ON pagos (proveedor_id, referencia_externa)
    WHERE referencia_externa IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_pagos_proveedor_idempotencia
    ON pagos (proveedor_id, clave_idempotencia);

CREATE INDEX IF NOT EXISTS idx_pagos_reserva_fecha
    ON pagos (reserva_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_pagos_metodo_estado_fecha
    ON pagos (metodo_pago_id, estado_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_historial_estados_pago_pago_fecha
    ON historial_estados_pago (pago_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_confirmaciones_efectivo_confirmado_at
    ON confirmaciones_efectivo (confirmado_at DESC);
