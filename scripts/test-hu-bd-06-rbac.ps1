[CmdletBinding()]
param(
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-06-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-bd-06-rbac.sql"

if (-not (Test-Path $EnvFile)) {
    throw "Create an untracked .env file from .env.example before running this test."
}

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    docker cp $testSql "${postgresContainer}:/tmp/test-hu-bd-06-rbac.sql"
    docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-bd-06-rbac.sql'
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 9

    $rolesTableRemoved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''iam.roles'') IS NULL;"'
    if ($rolesTableRemoved.Trim() -ne "t") {
        throw "Liquibase did not remove the iam.roles table during rollback."
    }

    $passwordPoliciesPreserved = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT to_regclass(''iam.password_policies'') IS NOT NULL;"'
    if ($passwordPoliciesPreserved.Trim() -ne "t") {
        throw "HU-BD-06 rollback affected HU-BD-05 migrations."
    }

    Write-Host "HU-BD-06 Liquibase migration and rollback test passed."
}
finally {
    docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans
}
