[CmdletBinding()]
param(
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-24-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-bd-24-mileage-plans.sql"

if (-not (Test-Path $EnvFile)) {
    throw "Create an untracked .env file from .env.example before running this test."
}

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase --labels="hu-bd-01,hu-bd-02,hu-bd-03,hu-bd-04,hu-bd-05,hu-bd-06,hu-bd-07,hu-bd-08,hu-bd-09,hu-bd-10,hu-bd-11,hu-bd-12,hu-bd-13,hu-bd-14,hu-bd-15,hu-bd-16,hu-bd-17,hu-bd-18,hu-bd-19,hu-bd-20,hu-bd-21,hu-bd-22,hu-bd-23" update
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    docker cp $testSql "${postgresContainer}:/tmp/test-hu-bd-24-mileage-plans.sql"
    docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-bd-24-mileage-plans.sql'
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 3

    $plansRemoved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''catalog.mileage_plans'') IS NULL;"'
    if ($plansRemoved.Trim() -ne "t") {
        throw "Liquibase did not remove catalog.mileage_plans during rollback."
    }

    $coveragesPreserved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''catalog.insurance_coverages'') IS NOT NULL;"'
    if ($coveragesPreserved.Trim() -ne "t") {
        throw "HU-BD-24 rollback affected HU-BD-23 migrations."
    }

    Write-Host "HU-BD-24 Liquibase migration test passed."
}
finally {
    docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans
}
