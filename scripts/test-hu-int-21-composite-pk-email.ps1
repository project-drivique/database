[CmdletBinding()]
param([string]$EnvFile = ".env")

$ErrorActionPreference = "Stop"
$postgresContainer = "database-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-int-21-composite-pk-email.sql"

if (-not (Test-Path $EnvFile)) { throw "Create an untracked .env file from .env.example before running this test." }

function Invoke-Checked([scriptblock]$Command, [string]$Step) {
    & $Command
    if ($LASTEXITCODE -ne 0) { throw "Step failed: $Step" }
}

function Invoke-Scalar([string]$Sql) {
    $result = $Sql | docker exec -i $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tA -v ON_ERROR_STOP=1'
    if ($LASTEXITCODE -ne 0 -or $null -eq $result) { throw "Query failed: $Sql" }
    return ($result | Out-String).Trim()
}

try {
    # 1. Asegurar que PostgreSQL esté corriendo
    Write-Host "[1/6] Iniciando o verificando PostgreSQL..." -ForegroundColor Cyan
    Invoke-Checked { docker compose --env-file $EnvFile up -d postgres } "docker compose up postgres"

    # 2. Validar configuración y changelogs de Liquibase
    Write-Host "[2/6] Validando changelogs de Liquibase..." -ForegroundColor Cyan
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase validate } "liquibase validate"

    # 3. Aplicar migraciones (incluyendo hu-int-21)
    Write-Host "[3/6] Aplicando migraciones de Liquibase..." -ForegroundColor Cyan
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase update } "liquibase update"

    # 4. Copiar y ejecutar script SQL de pruebas funcionales y de integridad
    Write-Host "[4/6] Ejecutando pruebas SQL de Primary Key (id, email) y FKs..." -ForegroundColor Cyan
    Invoke-Checked { docker cp $testSql "${postgresContainer}:/tmp/test-hu-int-21-composite-pk-email.sql" } "copy test SQL"
    Invoke-Checked { docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-int-21-composite-pk-email.sql' } "run HU-INT-21 test"

    # 5. Probar rollback del changeset ddl-composite-pk-email-hu-int-21
    Write-Host "[5/6] Probando rollback de la Primary Key a id..." -ForegroundColor Cyan
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase rollback-count 1 } "liquibase rollback hu-int-21"

    # Verificar que el rollback devolvió la PK a solamente (id)
    $pkColsAfterRollback = Invoke-Scalar "SELECT array_agg(a.attname ORDER BY array_position(c.conkey, a.attnum)) FROM pg_constraint c JOIN pg_class t ON c.conrelid = t.oid JOIN pg_namespace n ON t.relnamespace = n.oid JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey) WHERE n.nspname = 'iam' AND t.relname = 'users' AND c.contype = 'p';"
    if ($pkColsAfterRollback -ne "{id}") {
        throw "Expected PK after rollback to be {id}, but got: $pkColsAfterRollback"
    }

    # 6. Re-aplicar migración para dejar la base de datos lista con la Primary Key compuesta
    Write-Host "[6/6] Re-aplicando migraciones para dejar el entorno listo..." -ForegroundColor Cyan
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase update } "re-apply liquibase update"

    Write-Host ""
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host " [PASS] HU-INT-21: Primary Key (id, email) y rollback verificados con exito." -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Green
}
finally {
    # Keep container running
}
