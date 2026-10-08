[CmdletBinding()]
param([string]$EnvFile = ".env")

$ErrorActionPreference = "Stop"
$projectName = "drivique-hu-int-12-test"
$postgresContainer = "database-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-int-12-reservation-lifecycle.sql"

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
    # Assuming postgres is already running
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase validate } "liquibase validate"
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase --labels="!hu-int-07 and !hu-int-08 and !hu-int-09 and !hu-int-10 and !hu-int-11" update } "liquibase update"

    Invoke-Checked { docker cp $testSql "${postgresContainer}:/tmp/test-hu-int-12-reservation-lifecycle.sql" } "copy test"
    Invoke-Checked { docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-int-12-reservation-lifecycle.sql' } "run HU-INT-12 test"

    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase rollback-count 1 } "liquibase rollback"

    $grantsRemoved = Invoke-Scalar "SELECT NOT has_table_privilege('drivique_app', 'rental.rental_extension_requests', 'INSERT');"
    if ($grantsRemoved -ne "t") { throw "Expected HU-INT-12 grants to be removed by rollback." }

    Write-Host "HU-INT-12 Liquibase migration, lifecycle grants and rollback test passed."
}
finally {
    # Keep container running, do nothing
}
