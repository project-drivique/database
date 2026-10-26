-- Eliminar la cuenta deja la fila anonimizada con estado DELETED. La restriccion original no lo permitia y
-- editar el CREATE TABLE no cambia las bases que ya existen: aqui se corrige la restriccion de verdad (idempotente).
ALTER TABLE iam.users DROP CONSTRAINT IF EXISTS chk_users_account_status;
ALTER TABLE iam.users ADD CONSTRAINT chk_users_account_status
    CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'LOCKED', 'PENDING_VERIFICATION', 'DELETED'));
