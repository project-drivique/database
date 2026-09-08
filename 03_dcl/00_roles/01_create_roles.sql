-- ==============================================================================
-- Drivique - Creación de Roles de Base de Datos (DCL)
-- ==============================================================================

DO $$
BEGIN
    -- 1. Rol de Migración y Administración de Esquema (Flyway / Migrator)
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'drivique_migrator') THEN
        CREATE ROLE drivique_migrator WITH LOGIN PASSWORD 'drivique_migrator_dev_pass';
    END IF;

    -- 2. Rol de Aplicación (Spring Boot - Privilegios Mínimos CRUD)
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'drivique_app') THEN
        CREATE ROLE drivique_app WITH LOGIN PASSWORD 'drivique_app_dev_pass';
    END IF;
END
$$;
