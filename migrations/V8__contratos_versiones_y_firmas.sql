-- =============================================================================
-- Flyway Migration: V8__contratos_versiones_y_firmas.sql
-- Historia: HU-BD-09 - Persistir contratos, versiones y firmas
-- =============================================================================

ALTER TABLE estados_contrato
    ADD COLUMN IF NOT EXISTS es_activo BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS es_final BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO estados_contrato (codigo, nombre, es_activo, es_final)
VALUES
    ('BORRADOR', 'Borrador', FALSE, FALSE),
    ('PENDIENTE_FIRMA', 'Pendiente de firma', TRUE, FALSE),
    ('ACTIVO', 'Activo', TRUE, FALSE),
    ('FINALIZADO', 'Finalizado', FALSE, TRUE),
    ('CANCELADO', 'Cancelado', FALSE, TRUE)
ON CONFLICT (codigo) DO UPDATE
SET nombre = EXCLUDED.nombre,
    es_activo = EXCLUDED.es_activo,
    es_final = EXCLUDED.es_final;

-- Un contrato sin reserva no puede representar una obligacion de alquiler.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM contratos_alquiler WHERE reserva_id IS NULL) THEN
        RAISE EXCEPTION 'No se puede aplicar V8: existen contratos sin reserva asociada';
    END IF;
END;
$$;

ALTER TABLE contratos_alquiler
    ALTER COLUMN reserva_id SET NOT NULL;

CREATE TABLE IF NOT EXISTS contrato_versiones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID NOT NULL REFERENCES contratos_alquiler(id) ON DELETE RESTRICT,
    numero_version SMALLINT NOT NULL CHECK (numero_version > 0),
    documento_url VARCHAR(1000),
    documento_hash CHAR(64),
    motivo VARCHAR(500),
    creado_por UUID REFERENCES usuarios(id),
    creado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (contrato_id, numero_version),
    CHECK (documento_hash IS NULL OR documento_hash ~ '^[0-9A-Fa-f]{64}$')
);

CREATE TABLE IF NOT EXISTS firmas_contrato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_version_id UUID NOT NULL REFERENCES contrato_versiones(id) ON DELETE RESTRICT,
    firmante_id UUID NOT NULL REFERENCES usuarios(id),
    tipo_firma VARCHAR(30) NOT NULL CHECK (tipo_firma IN ('TRAZO', 'ELECTRONICA', 'PLATAFORMA')),
    evidencia_url VARCHAR(1000),
    evidencia_hash CHAR(64) NOT NULL CHECK (evidencia_hash ~ '^[0-9A-Fa-f]{64}$'),
    trazos JSONB,
    ip_origen INET,
    user_agent VARCHAR(500),
    firmado_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (contrato_version_id, firmante_id),
    CHECK (evidencia_url IS NOT NULL OR trazos IS NOT NULL)
);

-- Conserva la evidencia disponible antes de V8 como la primera version.
INSERT INTO contrato_versiones (
    contrato_id, numero_version, documento_url, documento_hash, creado_at
)
SELECT c.id, 1, c.pdf_url, NULL, c.created_at
FROM contratos_alquiler c
WHERE c.pdf_url IS NOT NULL
ON CONFLICT (contrato_id, numero_version) DO NOTHING;

CREATE OR REPLACE FUNCTION validar_vinculo_inmutable_contrato_reserva()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_reserva RECORD;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.reserva_id IS DISTINCT FROM OLD.reserva_id THEN
        RAISE EXCEPTION 'La reserva de un contrato es inmutable'
            USING ERRCODE = '23514';
    END IF;

    SELECT cliente_id, vehiculo_id, sede_recogida_id, sede_devolucion_id,
           fecha_recogida, fecha_devolucion
    INTO v_reserva
    FROM reservas
    WHERE id = NEW.reserva_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La reserva asociada no existe'
            USING ERRCODE = '23503';
    END IF;

    IF NEW.cliente_id IS DISTINCT FROM v_reserva.cliente_id
       OR NEW.vehiculo_id IS DISTINCT FROM v_reserva.vehiculo_id
       OR NEW.sede_recogida_id IS DISTINCT FROM v_reserva.sede_recogida_id
       OR NEW.sede_devolucion_id IS DISTINCT FROM v_reserva.sede_devolucion_id
       OR NEW.inicio_programado_at IS DISTINCT FROM v_reserva.fecha_recogida
       OR NEW.fin_programado_at IS DISTINCT FROM v_reserva.fecha_devolucion THEN
        RAISE EXCEPTION 'El contrato debe conservar los datos de cliente, vehiculo, sucursales y periodo de la reserva'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION proteger_version_contrato()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Las versiones de contrato son inmutables; cree una nueva version'
        USING ERRCODE = '23514';
END;
$$;

CREATE OR REPLACE FUNCTION proteger_firma_contrato()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Las evidencias de firma son inmutables'
        USING ERRCODE = '23514';
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_vinculo_inmutable_contrato ON contratos_alquiler;
CREATE TRIGGER trg_validar_vinculo_inmutable_contrato
BEFORE INSERT OR UPDATE ON contratos_alquiler
FOR EACH ROW
EXECUTE FUNCTION validar_vinculo_inmutable_contrato_reserva();

DROP TRIGGER IF EXISTS trg_proteger_version_contrato ON contrato_versiones;
CREATE TRIGGER trg_proteger_version_contrato
BEFORE UPDATE OR DELETE ON contrato_versiones
FOR EACH ROW
EXECUTE FUNCTION proteger_version_contrato();

DROP TRIGGER IF EXISTS trg_proteger_firma_contrato ON firmas_contrato;
CREATE TRIGGER trg_proteger_firma_contrato
BEFORE UPDATE OR DELETE ON firmas_contrato
FOR EACH ROW
EXECUTE FUNCTION proteger_firma_contrato();

-- La restriccion UNIQUE existente sobre reserva_id, ahora no nullable, permite
-- un solo contrato por reserva y por tanto bloquea contratos activos duplicados.
CREATE INDEX IF NOT EXISTS idx_contratos_reserva_fecha
    ON contratos_alquiler (reserva_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_contratos_cliente_fecha
    ON contratos_alquiler (cliente_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_contratos_estado_fecha
    ON contratos_alquiler (estado_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_contrato_versiones_contrato_version
    ON contrato_versiones (contrato_id, numero_version DESC);

CREATE INDEX IF NOT EXISTS idx_firmas_contrato_version_fecha
    ON firmas_contrato (contrato_version_id, firmado_at DESC);
