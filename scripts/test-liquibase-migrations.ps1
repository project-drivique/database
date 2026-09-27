[CmdletBinding()]
param(
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-bd-01-test"

if (-not (Test-Path $EnvFile)) {
    throw "Create an untracked .env file from .env.example before running this test."
}

try {
    docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate
    docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase update
    $postgresContainer = "$projectName-postgres-1"
    $extension = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT extname FROM pg_extension WHERE extname = ''pgcrypto'';"'
    if ($extension.Trim() -ne "pgcrypto") {
        throw "Liquibase did not enable the pgcrypto extension."
    }

    $changesetCount = docker exec $postgresContainer `
        sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT COUNT(*) FROM databasechangelog WHERE id = ''001-enable-pgcrypto'';"'
    if ($changesetCount.Trim() -ne "1") {
        throw "Liquibase did not record the HU-BD-01 changeset."
    }

    Write-Host "HU-BD-01 Liquibase migration test passed."
}
finally {
    docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans
}
