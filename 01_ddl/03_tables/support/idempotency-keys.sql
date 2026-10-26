-- Protocolo de idempotencia (cabecera Idempotency-Key): guarda el resultado de cada operacion de reservas y pagos
-- para devolver la MISMA respuesta si el cliente repite la peticion (doble clic, reintento de red, timeout).
-- La restriccion unica (persona, clave) es lo que serializa dos peticiones simultaneas con la misma clave.
CREATE TABLE IF NOT EXISTS support.idempotency_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_email VARCHAR(254) NOT NULL,
    idempotency_key VARCHAR(80) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_path VARCHAR(255) NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    status VARCHAR(12) NOT NULL,
    response_status INTEGER,
    response_content_type VARCHAR(100),
    response_body TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_idempotency_keys_scope UNIQUE (user_email, idempotency_key),
    CONSTRAINT chk_idempotency_keys_status CHECK (status IN ('IN_PROGRESS', 'COMPLETED'))
);

CREATE INDEX IF NOT EXISTS idx_idempotency_keys_expires ON support.idempotency_keys (expires_at);
