# 🗄️ Drivique - Repositorio de Base de Datos

Repositorio central para la definición, versionamiento, migración y mantenimiento de los esquemas, datos y seguridad de la base de datos del proyecto **Drivique**.

---

## 🌿 Estrategia de Ramas

El proyecto utiliza un flujo de trabajo estructurado para garantizar la estabilidad y control en cada entorno:

- **`main`**: **Producción.** Contiene los scripts y migraciones estables ya desplegados en el entorno productivo.
- **`qa`**: **Pruebas / Staging.** Ambiente para validación, testing integral y control de calidad.
- **`dev`**: **Desarrollo.** Rama de integración continua donde convergen las nuevas características antes de pasar a QA.
- **`HU-BD-XX-dev`**: Rama hija creada desde `dev` para implementar una historia de usuario. Las promociones usan `HU-BD-XX-qa` y `HU-BD-XX-main`.

---

## 🛫 Migraciones Liquibase

Liquibase es el único gestor de migraciones del proyecto. El archivo
`changelog/db.changelog-master.yaml` incluye los changesets SQL versionados y
los ejecuta en orden. Cada HU-BD agrega un changeset nuevo en
`changelog/changesets/` y lo registra en el changelog maestro.

Para validar localmente, copia `.env.example` a `.env` y ejecuta:

```powershell
.\scripts\test-liquibase-migrations.ps1
```

La prueba crea un proyecto Docker temporal, valida el changelog, aplica los
changesets y elimina sus recursos al finalizar.

---

## 📁 Estructura del Repositorio

La arquitectura del proyecto sigue el estándar de separación por sub-lenguajes SQL y orden de dependencia secuencial:

```text
database/
├── 01_ddl/                     # Definición de datos (Data Definition Language)
│   ├── 00_extensions/          # Extensiones (ej. uuid-ossp, pgcrypto, etc.)
│   ├── 01_schemas/             # Creación de esquemas lógicos
│   ├── 02_types/               # Tipos de datos personalizados, ENUMs, dominios
│   ├── 03_tables/              # Tablas de la base de datos
│   ├── 04_constraints/         # Llaves primarias, foráneas, checks y uniques
│   ├── 05_views/               # Vistas estándar
│   ├── 06_materialized_views/  # Vistas materializadas
│   ├── 07_functions/           # Funciones
│   ├── 08_procedures/          # Procedimientos almacenados
│   ├── 09_triggers/            # Disparadores (Triggers)
│   ├── 10_indexes/             # Índices para optimización de consultas
│   └── 11_schema_assignments/  # Asignaciones y configuraciones de esquemas
│
├── 02_dml/                     # Manipulación de datos (Data Manipulation Language)
│   ├── 00_inserts/             # Semillas iniciales (seeds) y catálogos
│   ├── 01_updates/             # Modificaciones y actualizaciones de datos
│   ├── 02_deletes/             # Eliminaciones controladas
│   ├── 03_upserts/             # Inserciones con conflicto (ON CONFLICT / MERGE)
│   └── 04_patches/             # Parches de corrección de datos
│
├── 03_dcl/                     # Control de acceso y seguridad (Data Control Language)
│   ├── 00_roles/               # Creación de roles y usuarios
│   └── 01_grants/              # Asignación de permisos y privilegios
│
├── 04_tcl/                     # Control de transacciones (Transaction Control Language)
│   ├── 00_transaction_blocks/  # Bloques transaccionales (BEGIN, COMMIT, SAVEPOINT)
│   ├── 01_manual_recoveries/   # Scripts de recuperación manual
│   └── 02_release_tags/        # Tags y puntos de control de releases
│
├── 05_rollbacks/               # Scripts de reversión (Espejo de 01 a 04)
│   ├── 01_ddl/                 # Reversión de cambios DDL (DROP TABLE, etc.)
│   ├── 02_dml/                 # Reversión de datos DML
│   ├── 03_dcl/                 # Reversión de permisos DCL
│   └── 04_tcl/                 # Reversión transaccional
│
├── changelog/                  # Orquestación y versionamiento (Liquibase / Changelogs)
│   └── db.changelog-master.yaml
│
├── scripts/                    # Scripts de utilidad, automatización o despliegue
├── .gitignore                  # Exclusión de archivos sensibles y temporales
└── README.md                   # Documentación general del repositorio
```

---

## 🚀 Flujo de Desarrollo

1. **Crear rama desde `dev`:**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b HU-BD-XX-dev
   ```

2. **Agregar un changeset de Liquibase:**
   - Crea un SQL formateado de Liquibase en `changelog/changesets/`.
   - Regístralo en `changelog/db.changelog-master.yaml`.
   - Agrega rollback solo cuando sea técnicamente seguro y no afecte changesets posteriores.

3. **Subir cambios y abrir Pull Request hacia `dev`:**
   ```bash
   git add .
   git commit -m "feat(database): add user and permission tables"
   git push -u origin HU-BD-XX-dev
   ```

---

## 📌 Buenas Prácticas

- **Scripts Idempotentes:** Procura usar sentencias seguras como `CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`, `DROP TABLE IF EXISTS`, etc.
- **Rollback obligatorio:** Todo script que aplique un cambio debe tener su script de reversión asociado en `05_rollbacks/`.
- **Seguridad:** Nunca commitear credenciales, archivos `.env` o volcados con datos sensibles o de producción.
