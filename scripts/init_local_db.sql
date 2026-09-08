-- ==============================================================================
-- Drivique - Script de inicialización y orquestación local
-- ==============================================================================
-- Este script ejecuta secuencialmente:
-- 1. Extensiones (pgcrypto, uuid-ossp)
-- 2. DDL Tablas e Índices
-- 3. DCL Roles y Privilegios
-- ==============================================================================

\echo '--- Habilitando Extensiones ---'
\i 01_ddl/00_extensions/01_enable_pgcrypto.sql

\echo '--- Creando Tablas y Restricciones ---'
\i 01_ddl/03_tables/01_tablas_drivique.sql

\echo '--- Creando Índices ---'
\i 01_ddl/10_indexes/01_indices_ciudades_sucursales.sql

\echo '--- Insertando Semillas DML ---'
\i 02_dml/00_inserts/01_seed_roles_permisos.sql
\i 02_dml/00_inserts/02_seed_documentos_catalogos.sql
\i 02_dml/00_inserts/03_seed_ciudades_sucursales.sql

\echo '--- Configurando Roles y Permisos DCL ---'
\i 03_dcl/00_roles/01_create_roles.sql
\i 03_dcl/01_grants/01_grant_privileges.sql

\echo '=== Inicialización de Base de Datos Drivique Completada con Éxito ==='
