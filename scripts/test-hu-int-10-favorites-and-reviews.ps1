[CmdletBinding()]
param([string]$EnvFile = ".env")

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-int-10-test"
$postgresContainer = "$projectName-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-int-10-favorites-and-reviews.sql"

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
    Invoke-Checked { docker compose --project-name $projectName --env-file $EnvFile up --detach --wait postgres } "start postgres"
    Invoke-Checked { docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase validate } "liquibase validate"
    Invoke-Checked { docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase --labels="!hu-int-07 and !hu-int-08 and !hu-int-09" update } "liquibase update"

    Invoke-Checked { docker cp $testSql "${postgresContainer}:/tmp/test-hu-int-10-favorites-and-reviews.sql" } "copy test"
    Invoke-Checked { docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-int-10-favorites-and-reviews.sql' } "run HU-INT-10 test"

    Invoke-Checked { docker compose --project-name $projectName --env-file $EnvFile run --rm liquibase rollback-count 1 } "liquibase rollback"

    $grantsRemoved = Invoke-Scalar "SELECT NOT has_table_privilege('drivique_app', 'fleet.user_favorite_vehicles', 'INSERT') AND NOT has_schema_privilege('drivique_app', 'rental', 'USAGE');"
    if ($grantsRemoved -ne "t") { throw "Expected HU-INT-10 grants to be removed by rollback." }

    $tablesPreserved = Invoke-Scalar "SELECT to_regclass('fleet.user_favorite_vehicles') IS NOT NULL AND to_regclass('rental.vehicle_ratings') IS NOT NULL AND to_regclass('rental.branch_reviews') IS NOT NULL;"
    if ($tablesPreserved -ne "t") { throw "Rollback removed favorites or reviews tables." }

    $catalogGrantPreserved = Invoke-Scalar "SELECT has_table_privilege('drivique_app', 'fleet.vehicles', 'SELECT');"
    if ($catalogGrantPreserved -ne "t") { throw "Rollback removed a HU-INT-04 catalog grant." }

    Write-Host "HU-INT-10 Liquibase migration, favorites/reviews and rollback test passed."
}
finally { docker compose --project-name $projectName --env-file $EnvFile down --volumes --remove-orphans }
