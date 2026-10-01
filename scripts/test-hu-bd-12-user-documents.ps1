[CmdletBinding()]
param(
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-12-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-bd-12-user-documents.sql"

if (-not (Test-Path $EnvFile)) {
    throw "Create an untracked .env file from .env.example before running this test."
}

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase --labels="hu-bd-01,hu-bd-02,hu-bd-03,hu-bd-04,hu-bd-05,hu-bd-06,hu-bd-07,hu-bd-08,hu-bd-09,hu-bd-10,hu-bd-11" update
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    docker cp $testSql "${postgresContainer}:/tmp/test-hu-bd-12-user-documents.sql"
    docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-bd-12-user-documents.sql'
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 5

    $documentsRemoved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''iam.user_documents'') IS NULL;"'
    if ($documentsRemoved.Trim() -ne "t") {
        throw "Liquibase did not remove user_documents during rollback."
    }

    $identityCatalogsPreserved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''iam.document_types'') IS NOT NULL AND to_regclass(''iam.document_statuses'') IS NOT NULL;"'
    if ($identityCatalogsPreserved.Trim() -ne "t") {
        throw "HU-BD-12 rollback affected HU-BD-11 identity catalogs."
    }

    Write-Host "HU-BD-12 Liquibase migration test passed."
}
finally {
    docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans
}
