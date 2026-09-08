[CmdletBinding()]
param(
    [string]$RepositoryPath,
    [string]$PostgresImage = 'postgres:17-alpine',
    [string]$FlywayImage = 'flyway/flyway:11.8.0'
)

$ErrorActionPreference = 'Stop'
if (-not $RepositoryPath) {
    $RepositoryPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$containerName = 'drivique-hu09-postgres-test'
$temporaryPath = Join-Path ([System.IO.Path]::GetTempPath()) ('drivique-hu09-' + [guid]::NewGuid())
$legacyMigrationsPath = Join-Path $temporaryPath 'legacy-migrations'
$migrationsPath = Join-Path $RepositoryPath 'migrations'
$testPath = Join-Path $RepositoryPath 'scripts\test_hu_bd_09_contratos.sql'

function Invoke-FlywayMigration {
    param([string]$Database, [string]$SqlPath)

    & docker run --rm --network "container:$containerName" `
        -v "${SqlPath}:/flyway/sql:ro" $FlywayImage `
        "-url=jdbc:postgresql://localhost:5432/$Database" `
        '-user=drivique_admin' '-password=drivique_test_pass' '-connectRetries=10' migrate

    if ($LASTEXITCODE -ne 0) {
        throw "Flyway no pudo migrar la base $Database."
    }
}

function Remove-TestContainer {
    $existingContainer = & docker ps -aq --filter "name=^/$containerName$"
    if ($LASTEXITCODE -ne 0) {
        throw 'No fue posible consultar los contenedores de Docker.'
    }
    if ($existingContainer) {
        & docker rm -f $containerName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw 'No fue posible eliminar el contenedor temporal de pruebas.'
        }
    }
}

try {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw 'Docker Desktop es requerido para ejecutar esta prueba de migraciones.'
    }

    New-Item -ItemType Directory -Path $legacyMigrationsPath -Force | Out-Null
    Get-ChildItem $migrationsPath -File |
        Where-Object { $_.Name -match '^V[1-7]__.*\.sql$' } |
        Copy-Item -Destination $legacyMigrationsPath

    if ((Get-ChildItem $legacyMigrationsPath -File).Count -ne 7) {
        throw 'No se pudieron preparar las migraciones V1 a V7 para el escenario de actualizacion.'
    }

    Remove-TestContainer
    & docker run --rm -d --name $containerName `
        -e POSTGRES_USER=drivique_admin `
        -e POSTGRES_PASSWORD=drivique_test_pass `
        -e POSTGRES_DB=drivique_hu09_clean `
        $PostgresImage | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw 'No fue posible iniciar el contenedor aislado de PostgreSQL.'
    }

    Invoke-FlywayMigration -Database 'drivique_hu09_clean' -SqlPath $migrationsPath

    & docker exec $containerName createdb -U drivique_admin drivique_hu09_upgrade
    if ($LASTEXITCODE -ne 0) {
        throw 'No fue posible crear la base para el escenario de actualizacion.'
    }

    Invoke-FlywayMigration -Database 'drivique_hu09_upgrade' -SqlPath $legacyMigrationsPath
    Invoke-FlywayMigration -Database 'drivique_hu09_upgrade' -SqlPath $migrationsPath

    & docker cp $testPath "${containerName}:/tmp/test_hu_bd_09_contratos.sql"
    & docker exec $containerName psql -v ON_ERROR_STOP=1 -U drivique_admin -d drivique_hu09_upgrade -f /tmp/test_hu_bd_09_contratos.sql
    if ($LASTEXITCODE -ne 0) {
        throw 'Fallaron las pruebas de integridad de HU-BD-09.'
    }

    Write-Host 'Migracion limpia, actualizacion V7 -> V8 y pruebas HU-BD-09 aprobadas.'
}
finally {
    $existingContainer = & docker ps -aq --filter "name=^/$containerName$" 2>$null
    if ($existingContainer) {
        & docker rm -f $containerName 2>$null | Out-Null
    }
    Remove-Item -LiteralPath $temporaryPath -Recurse -Force -ErrorAction SilentlyContinue
}
