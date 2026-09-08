-- =============================================================================
-- Flyway Migration: V7__reservas_y_maquina_de_estados.sql
-- Historia: HU-BD-07 - Persistir reservas y su maquina de estados
-- =============================================================================

-- btree_gist permite combinar UUID y rangos de tiempo en una exclusion GIST.
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Las columnas nuevas se mantienen nullable para que la migracion pueda
-- actualizar bases existentes. El trigger exige las sucursales en reservas nuevas.
ALTER TABLE reservas
    ADD COLUMN IF NOT EXISTS sede_recogida_id UUID REFERENCES sedes(id),
    ADD COLUMN IF NOT EXISTS sede_devolucion_id UUID REFERENCES sedes(id),
    ADD COLUMN IF NOT EXISTS periodo TSTZRANGE GENERATED ALWAYS AS (
        tstzrange(fecha_recogida, fecha_devolucion, '[)')
    ) STORED,
    ADD COLUMN IF NOT EXISTS bloquea_disponibilidad BOOLEAN NOT NULL DEFAULT FALSE;

-- Conserva la compatibilidad con reservas historicas que solo tenian puntos.
UPDATE reservas r
SET sede_recogida_id = p.sede_id
FROM puntos_reserva p
WHERE p.reserva_id = r.id
  AND p.tipo = 'RECOGIDA'
  AND p.modalidad = 'SUCURSAL'
  AND r.sede_recogida_id IS NULL;

UPDATE reservas r
SET sede_devolucion_id = p.sede_id
FROM puntos_reserva p
WHERE p.reserva_id = r.id
  AND p.tipo = 'DEVOLUCION'
  AND p.modalidad = 'SUCURSAL'
  AND r.sede_devolucion_id IS NULL;

INSERT INTO estados_reserva (codigo, nombre, bloquea_disponibilidad)
VALUES
    ('PENDIENTE_PAGO', 'Pendiente de pago', TRUE),
    ('CONFIRMADA', 'Confirmada', TRUE),
    ('EN_CURSO', 'En curso', TRUE),
    ('COMPLETADA', 'Completada', FALSE),
    ('CANCELADA', 'Cancelada', FALSE),
    ('EXPIRADA', 'Expirada', FALSE)
ON CONFLICT (codigo) DO UPDATE
SET nombre = EXCLUDED.nombre,
    bloquea_disponibilidad = EXCLUDED.bloquea_disponibilidad;

UPDATE reservas r
SET bloquea_disponibilidad = er.bloquea_disponibilidad
FROM estados_reserva er
WHERE er.id = r.estado_id;

CREATE TABLE IF NOT EXISTS transiciones_estado_reserva (
    estado_origen_id UUID NOT NULL REFERENCES estados_reserva(id),
    estado_destino_id UUID NOT NULL REFERENCES estados_reserva(id),
    descripcion VARCHAR(255) NOT NULL,
    PRIMARY KEY (estado_origen_id, estado_destino_id),
    CHECK (estado_origen_id <> estado_destino_id)
);

INSERT INTO transiciones_estado_reserva (estado_origen_id, estado_destino_id, descripcion)
SELECT origen.id, destino.id, flujo.descripcion
FROM (
    VALUES
        ('PENDIENTE_PAGO', 'CONFIRMADA', 'Pago validado y reserva confirmada.'),
        ('PENDIENTE_PAGO', 'CANCELADA', 'Cliente o sistema cancela antes de confirmar.'),
        ('PENDIENTE_PAGO', 'EXPIRADA', 'Vence el plazo de pago.'),
        ('CONFIRMADA', 'EN_CURSO', 'Se entrega el vehiculo al cliente.'),
        ('CONFIRMADA', 'CANCELADA', 'Cancelacion antes de la entrega.'),
        ('EN_CURSO', 'COMPLETADA', 'Vehiculo devuelto y alquiler finalizado.')
) AS flujo(origen_codigo, destino_codigo, descripcion)
JOIN estados_reserva origen ON origen.codigo = flujo.origen_codigo
JOIN estados_reserva destino ON destino.codigo = flujo.destino_codigo
ON CONFLICT (estado_origen_id, estado_destino_id) DO UPDATE
SET descripcion = EXCLUDED.descripcion;

CREATE TABLE IF NOT EXISTS historial_estados_reserva (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reserva_id UUID NOT NULL REFERENCES reservas(id) ON DELETE CASCADE,
    estado_anterior_id UUID REFERENCES estados_reserva(id),
    estado_nuevo_id UUID NOT NULL REFERENCES estados_reserva(id),
    cambiado_por UUID REFERENCES usuarios(id),
    motivo VARCHAR(500),
    creado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION validar_estado_y_disponibilidad_reserva()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_bloquea_disponibilidad BOOLEAN;
BEGIN
    SELECT bloquea_disponibilidad
    INTO v_bloquea_disponibilidad
    FROM estados_reserva
    WHERE id = NEW.estado_id;

    IF v_bloquea_disponibilidad IS NULL THEN
        RAISE EXCEPTION 'El estado de reserva indicado no existe'
            USING ERRCODE = '23503';
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NEW.sede_recogida_id IS NULL OR NEW.sede_devolucion_id IS NULL THEN
            RAISE EXCEPTION 'Toda reserva nueva debe indicar sucursal de recogida y devolucion'
                USING ERRCODE = '23514';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM estados_reserva
            WHERE id = NEW.estado_id AND codigo = 'PENDIENTE_PAGO'
        ) THEN
            RAISE EXCEPTION 'Toda reserva debe iniciar en estado PENDIENTE_PAGO'
                USING ERRCODE = '23514';
        END IF;
    ELSIF NEW.estado_id IS DISTINCT FROM OLD.estado_id
       AND NOT EXISTS (
            SELECT 1
            FROM transiciones_estado_reserva
            WHERE estado_origen_id = OLD.estado_id
              AND estado_destino_id = NEW.estado_id
       ) THEN
        RAISE EXCEPTION 'Transicion de estado de reserva no permitida'
            USING ERRCODE = '23514';
    END IF;

    NEW.bloquea_disponibilidad := v_bloquea_disponibilidad;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION registrar_historial_estado_reserva()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' OR NEW.estado_id IS DISTINCT FROM OLD.estado_id THEN
        INSERT INTO historial_estados_reserva (
            reserva_id, estado_anterior_id, estado_nuevo_id
        )
        VALUES (
            NEW.id,
            CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE OLD.estado_id END,
            NEW.estado_id
        );
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_estado_y_disponibilidad_reserva ON reservas;
CREATE TRIGGER trg_validar_estado_y_disponibilidad_reserva
BEFORE INSERT OR UPDATE OF estado_id, sede_recogida_id, sede_devolucion_id ON reservas
FOR EACH ROW
EXECUTE FUNCTION validar_estado_y_disponibilidad_reserva();

DROP TRIGGER IF EXISTS trg_registrar_historial_estado_reserva ON reservas;
CREATE TRIGGER trg_registrar_historial_estado_reserva
AFTER INSERT OR UPDATE OF estado_id ON reservas
FOR EACH ROW
EXECUTE FUNCTION registrar_historial_estado_reserva();

ALTER TABLE reservas
    DROP CONSTRAINT IF EXISTS reservas_vehiculo_periodo_sin_solapamiento;

ALTER TABLE reservas
    ADD CONSTRAINT reservas_vehiculo_periodo_sin_solapamiento
    EXCLUDE USING gist (
        vehiculo_id WITH =,
        periodo WITH &&
    )
    WHERE (bloquea_disponibilidad);

CREATE INDEX IF NOT EXISTS idx_reservas_cliente_fecha
    ON reservas (cliente_id, fecha_recogida DESC);

CREATE INDEX IF NOT EXISTS idx_reservas_estado_fecha
    ON reservas (estado_id, fecha_recogida DESC);

CREATE INDEX IF NOT EXISTS idx_reservas_sede_recogida_fecha
    ON reservas (sede_recogida_id, fecha_recogida DESC);

CREATE INDEX IF NOT EXISTS idx_reservas_vehiculo_periodo
    ON reservas (vehiculo_id, fecha_recogida, fecha_devolucion)
    WHERE bloquea_disponibilidad;

CREATE INDEX IF NOT EXISTS idx_historial_estados_reserva_reserva_fecha
    ON historial_estados_reserva (reserva_id, creado_at DESC);
