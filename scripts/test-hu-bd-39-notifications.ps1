[CmdletBinding()]
param([string]$EnvFile = ".env")

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-39-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-bd-39-notifications.sql"

if (-not (Test-Path $EnvFile)) { throw "Create an untracked .env file from .env.example before running this test." }

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase --labels="hu-bd-01,hu-bd-02,hu-bd-03,hu-bd-04,hu-bd-05,hu-bd-06,hu-bd-07,hu-bd-08,hu-bd-09,hu-bd-10,hu-bd-11,hu-bd-12,hu-bd-13,hu-bd-14,hu-bd-15,hu-bd-16,hu-bd-17,hu-bd-18,hu-bd-19,hu-bd-20,hu-bd-21,hu-bd-22,hu-bd-23,hu-bd-24,hu-bd-25,hu-bd-26,hu-bd-27,hu-bd-28,hu-bd-29,hu-bd-30,hu-bd-31,hu-bd-32,hu-bd-33,hu-bd-34,hu-bd-35,hu-bd-36,hu-bd-37,hu-bd-38" update
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    docker cp $testSql "${postgresContainer}:/tmp/test-hu-bd-39-notifications.sql"
    docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-bd-39-notifications.sql'
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 3

    $notificationsRemoved = docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''support.notifications'') IS NULL"'
    if ($notificationsRemoved.Trim() -ne "t") { throw "Expected HU-BD-39 tables to be removed by rollback." }

    $incidentsPreserved = docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''support.incident_reports'') IS NOT NULL"'
    if ($incidentsPreserved.Trim() -ne "t") { throw "Rollback removed a HU-BD-38 object." }

    Write-Host "HU-BD-39 Liquibase migration and rollback test passed."
}
finally { docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans }
