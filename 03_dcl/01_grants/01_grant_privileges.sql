-- ==============================================================================
-- Drivique - Asignación de Privilegios Mínimos (DCL)
-- ==============================================================================

-- 1. Privilegios para el rol de Migración (Flyway)
GRANT ALL PRIVILEGES ON SCHEMA public TO drivique_migrator;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO drivique_migrator;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO drivique_migrator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO drivique_migrator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO drivique_migrator;

-- 2. Privilegios Mínimos para el rol de Aplicación (Spring Boot)
-- Conexión y uso de esquema
GRANT USAGE ON SCHEMA public TO drivique_app;

-- Solo lectura y manipulación de datos (CRUD), sin permisos DDL (DROP, ALTER, CREATE)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO drivique_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO drivique_app;

-- Asegurar privilegios para tablas y secuencias creadas en futuras migraciones
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO drivique_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO drivique_app;
