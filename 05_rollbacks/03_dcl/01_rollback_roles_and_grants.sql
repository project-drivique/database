-- ==============================================================================
-- Drivique - Rollback de Roles y Permisos (DCL Reversal)
-- ==============================================================================

-- Revocar privilegios por defecto en esquema public
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM drivique_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM drivique_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM drivique_migrator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM drivique_migrator;

-- Revocar privilegios en objetos existentes
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM drivique_app;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM drivique_app;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM drivique_app;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM drivique_migrator;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM drivique_migrator;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM drivique_migrator;

-- Eliminar roles
DROP ROLE IF EXISTS drivique_app;
DROP ROLE IF EXISTS drivique_migrator;
