# Drivique - Repositorio de Base de Datos

Repositorio central para la definición, versionamiento, migración y mantenimiento de los esquemas, datos y seguridad de la base de datos PostgreSQL 17 del proyecto **Drivique** (78 tablas distribuidas en 8 esquemas de dominio).

---

## Estrategia de Ramas

El proyecto utiliza un flujo de trabajo estructurado para garantizar la estabilidad y control en cada entorno:

- **`main`**: **Producción.** Contiene los scripts y migraciones estables ya desplegados en el entorno productivo (`https://drivique.tech`).
- **`qa`**: **Pruebas / Staging.** Ambiente para validación, testing integral y control de calidad.
- **`dev`**: **Desarrollo.** Rama de integración continua donde convergen las nuevas características antes de pasar a QA.
- **`HU-BD-XX-dev` / `HU-INT-XX-dev`**: Rama hija creada desde `dev` para implementar una historia de usuario o remediación transversal.

---

## Migraciones Liquibase y CI Automatizado

Liquibase es el único gestor de migraciones del proyecto. El archivo
`changelog/db.changelog-master.yaml` incluye los changesets SQL versionados y
los ejecuta en orden. Los archivos se organizan bajo `01_ddl/`: primero por
tipo técnico y, en `03_tables/`, por dominio (`core`, `iam`, `location`, `fleet`, `rental`, `contract`, `billing`, `audit`). Cada dominio tiene su propio
`changelog.yaml` e incluye un archivo SQL por tabla (78 tablas en total). Los datos semilla se
organizan de la misma forma en `02_dml/00_inserts/<dominio>/`.

Cada SQL de avance tiene su reversión equivalente en `05_rollbacks/`, con la
misma ruta funcional y el sufijo `.rollback.sql`. El `changelog.yaml` enlaza
ambos archivos mediante `sqlFile`, de modo que Liquibase puede ejecutar el
rollback en orden inverso.

### Integración Continua (`.github/workflows/ci.yml`)
En cada Pull Request y push a `dev`, `qa` y `main`, el pipeline de GitHub Actions:
1. Levanta un contenedor `postgres:17-alpine` limpio.
2. Ejecuta `liquibase validate` y `liquibase update` sobre `changelog/db.changelog-master.yaml`.
3. Ejecuta automáticamente las **50 pruebas SQL** en `scripts/tests/*.sql` con `ON_ERROR_STOP=1`.
4. Verifica el rollback y re-aplicación del último changeset (`liquibase rollback-count --count=1` + `liquibase update`).

Para validar localmente, copia `.env.example` a `.env` y ejecuta:

```powershell
.\scripts\test-liquibase-migrations.ps1
```

Las pruebas específicas de una historia siguen el formato
`scripts/test-hu-bd-XX-<dominio>.ps1`. Por ejemplo, para HU-BD-02:

```powershell
.\scripts\test-hu-bd-02-core.ps1
```

### Remediación HU-INT-22-dev (Gobernanza y Calidad E2E)
- **H-26:** Automatización de las 50 suites SQL en CI bajo GitHub Actions (`.github/workflows/ci.yml`).
- **H-28:** Retiro definitivo de seeds huérfanos con credenciales expuestas (`seed-demo-realistic-data.sql`).
- **H-21:** Documentación rigurosa de las 78 tablas físicas alineadas con las entidades del backend.

---

## Decisiones de Diseño de Auditoría e Integridad Referencial

- **Integridad Referencial Estricta:** El esquema define 138 llaves foráneas (`FOREIGN KEY`), 94 índices optimizados y restricciones `CHECK` de dominio.
- **Bitácora Inmutable de Auditoría (`audit.audit_logs`):**
  - La columna `actor_user_id` referencia `iam.users(id)` con `ON DELETE RESTRICT` pero admite `NULL` para registrar eventos de seguridad previos a la autenticación (por ejemplo, intentos fallidos de inicio de sesión sobre correos inexistentes o webhooks externos de pasarela de pago).
  - La columna `entity_id` almacena el `UUID` del registro afectado sin una llave foránea polimórfica directa hacia una única tabla, ya que `audit.audit_logs` audita operaciones `INSERT`, `UPDATE` y `DELETE` transversalmente sobre los 8 esquemas y debe conservar la traza histórica incluso después de que una entidad de negocio sea eliminada físicamente.

---

## Estructura del Repositorio

La arquitectura del proyecto sigue el estándar de separación por sub-lenguajes SQL y orden de dependencia secuencial:

```text
database/
├── .github/workflows/ci.yml    # Pipeline CI (Liquibase + 50 pruebas SQL + rollback)
├── 01_ddl/                     # Definición de datos (Data Definition Language)
│   ├── 00_extensions/          # Extensiones (pgcrypto, btree_gist)
│   ├── 01_schemas/             # Creación de los 8 esquemas lógicos
│   ├── 02_types/               # Tipos de datos personalizados, ENUMs, dominios
│   ├── 03_tables/              # 78 tablas organizadas por dominio
│   ├── 04_constraints/         # Llaves primarias, foráneas, checks y uniques
│   ├── 07_functions/           # Funciones PL/pgSQL
│   ├── 09_triggers/            # Disparadores (Triggers)
│   └── 10_indexes/             # Índices para optimización de consultas
├── 02_dml/                     # Manipulación de datos (Data Manipulation Language)
│   └── 00_inserts/             # Semillas iniciales (seeds) y catálogos sin credenciales en texto plano
├── 03_dcl/                     # Control de acceso y seguridad (Data Control Language)
├── 04_tcl/                     # Control de transacciones (Transaction Control Language)
├── 05_rollbacks/               # Scripts de reversión (Espejo de 01 a 04)
├── changelog/                  # Orquestación y versionamiento (Liquibase / Changelogs)
│   └── db.changelog-master.yaml
├── scripts/                    # Scripts de automatización y 50 suites en scripts/tests/
├── .gitignore                  # Exclusión de archivos sensibles y temporales
└── README.md                   # Documentación general del repositorio
```

---

## Cuentas operativas (Super Admin y 6 encargados)

> [!IMPORTANT]
> Ninguna contraseña vive en este repositorio. Las semillas crean estas cuentas **bloqueadas** y la API les asigna la contraseña real al arrancar, a partir de variables de entorno.

| Rol | Correo | Contraseña |
|---|---|---|
| Super Admin | `admin@drivique.com` | variable `BOOTSTRAP_ADMIN_PASSWORD` |
| Encargados (Bogotá, Medellín Centro, Medellín Aeropuerto, Cali, Barranquilla, Cartagena) | `encargado.<sucursal>@drivique.com` | variable `BOOTSTRAP_BRANCH_ADMIN_PASSWORD` |

- Mínimo 12 caracteres. La API solo asigna la contraseña a cuentas que sigan bloqueadas o con una clave que estuvo publicada: nunca pisa una que la persona ya cambió.
- En desarrollo, si no defines las variables, la API genera una contraseña temporal aleatoria y la muestra una sola vez en el log.
- En qa/main, sin las variables las cuentas quedan bloqueadas hasta definirlas.
