[CmdletBinding()]
param([string]$EnvFile = ".env")

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-33-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-bd-33-payment-catalogs.sql"

if (-not (Test-Path $EnvFile)) { throw "Create an untracked .env file from .env.example before running this test." }

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase --labels="hu-bd-01,hu-bd-02,hu-bd-03,hu-bd-04,hu-bd-05,hu-bd-06,hu-bd-07,hu-bd-08,hu-bd-09,hu-bd-10,hu-bd-11,hu-bd-12,hu-bd-13,hu-bd-14,hu-bd-15,hu-bd-16,hu-bd-17,hu-bd-18,hu-bd-19,hu-bd-20,hu-bd-21,hu-bd-22,hu-bd-23,hu-bd-24,hu-bd-25,hu-bd-26,hu-bd-27,hu-bd-28,hu-bd-29,hu-bd-30,hu-bd-31,hu-bd-32" update
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    docker cp $testSql "${postgresContainer}:/tmp/test-hu-bd-33-payment-catalogs.sql"
    docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-bd-33-payment-catalogs.sql'
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 6

    $billingRemoved = docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = ''billing'');"'
    if ($billingRemoved.Trim() -ne "t") { throw "Liquibase did not remove the billing schema during rollback." }

    Write-Host "HU-BD-33 Liquibase migration test passed."
}
finally { docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans }
