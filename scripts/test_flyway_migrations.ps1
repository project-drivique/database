[CmdletBinding()]
param(
    [string]$RepositoryPath = (Resolve-Path "$PSScriptRoot\\.."),
    [string]$PostgresImage = 'postgres:17-alpine',
    [string]$FlywayImage = 'flyway/flyway:11.8.0'
)

$ErrorActionPreference = 'Stop'
$containerName = 'drivique-hu07-postgres-test'
$temporaryPath = Join-Path ([System.IO.Path]::GetTempPath()) ('drivique-hu07-' + [guid]::NewGuid())
$legacyMigrationsPath = Join-Path $temporaryPath 'legacy-migrations'
$migrationsPath = Join-Path $RepositoryPath 'migrations'
$testPath = Join-Path $RepositoryPath 'scripts\\test_hu_bd_07_reservas.sql'

function Invoke-FlywayMigration {
    param(
        [string]$Database,
        [string]$SqlPath
    )

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
    Get-ChildItem $migrationsPath -Filter 'V[1-6]__*.sql' | Copy-Item -Destination $legacyMigrationsPath

    Remove-TestContainer
    & docker run --rm -d --name $containerName `
        -e POSTGRES_USER=drivique_admin `
        -e POSTGRES_PASSWORD=drivique_test_pass `
        -e POSTGRES_DB=drivique_hu07_clean `
        $PostgresImage | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw 'No fue posible iniciar el contenedor aislado de PostgreSQL.'
    }

    # Escenario 1: una base vacia recibe todas las migraciones V1 a V7.
    Invoke-FlywayMigration -Database 'drivique_hu07_clean' -SqlPath $migrationsPath

    # Escenario 2: una base existente en V6 se actualiza exclusivamente con V7.
    & docker exec $containerName createdb -U drivique_admin drivique_hu07_upgrade
    if ($LASTEXITCODE -ne 0) {
        throw 'No fue posible crear la base para el escenario de actualizacion.'
    }

    Invoke-FlywayMigration -Database 'drivique_hu07_upgrade' -SqlPath $legacyMigrationsPath
    Invoke-FlywayMigration -Database 'drivique_hu07_upgrade' -SqlPath $migrationsPath

    & docker cp $testPath "${containerName}:/tmp/test_hu_bd_07_reservas.sql"
    & docker exec $containerName psql -v ON_ERROR_STOP=1 -U drivique_admin -d drivique_hu07_upgrade -f /tmp/test_hu_bd_07_reservas.sql
    if ($LASTEXITCODE -ne 0) {
        throw 'Fallaron las pruebas de integridad de HU-BD-07.'
    }

    Write-Host 'Migracion limpia, actualizacion V6 -> V7 y pruebas HU-BD-07 aprobadas.'
}
finally {
    $existingContainer = & docker ps -aq --filter "name=^/$containerName$" 2>$null
    if ($existingContainer) {
        & docker rm -f $containerName 2>$null | Out-Null
    }
    Remove-Item -LiteralPath $temporaryPath -Recurse -Force -ErrorAction SilentlyContinue
}
