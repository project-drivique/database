[CmdletBinding()]
param(
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-23-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-bd-23-services-and-coverages.sql"

if (-not (Test-Path $EnvFile)) {
    throw "Create an untracked .env file from .env.example before running this test."
}

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase --labels="hu-bd-01,hu-bd-02,hu-bd-03,hu-bd-04,hu-bd-05,hu-bd-06,hu-bd-07,hu-bd-08,hu-bd-09,hu-bd-10,hu-bd-11,hu-bd-12,hu-bd-13,hu-bd-14,hu-bd-15,hu-bd-16,hu-bd-17,hu-bd-18,hu-bd-19,hu-bd-20,hu-bd-21,hu-bd-22" update
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    docker cp $testSql "${postgresContainer}:/tmp/test-hu-bd-23-services-and-coverages.sql"
    docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-bd-23-services-and-coverages.sql'
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 6

    $catalogSchemaRemoved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = ''catalog'');"'
    if ($catalogSchemaRemoved.Trim() -ne "t") {
        throw "Liquibase did not remove the catalog schema during rollback."
    }

    $fleetPreserved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''fleet.vehicles'') IS NOT NULL;"'
    if ($fleetPreserved.Trim() -ne "t") {
        throw "HU-BD-23 rollback affected prior fleet migrations."
    }

    Write-Host "HU-BD-23 Liquibase migration test passed."
}
finally {
    docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans
}
