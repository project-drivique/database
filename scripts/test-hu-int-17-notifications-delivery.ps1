[CmdletBinding()]
param([string]$EnvFile = ".env")

$ErrorActionPreference = "Stop"
$postgresContainer = "database-postgres-1"
$testSql = Join-Path $PSScriptRoot "tests/test-hu-int-17-notifications-delivery.sql"

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
    # 1. Validate Liquibase configuration
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase validate } "liquibase validate"

    # 2. Apply migrations (including hu-int-17)
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase update } "liquibase update"

    # 3. Copy and run test SQL
    Invoke-Checked { docker cp $testSql "${postgresContainer}:/tmp/test-hu-int-17-notifications-delivery.sql" } "copy test"
    Invoke-Checked { docker exec $postgresContainer sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1 -f /tmp/test-hu-int-17-notifications-delivery.sql' } "run HU-INT-17 test"

    # 4. Test rollback of the 7 changesets of HU-INT-17
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase rollback-count 7 } "liquibase rollback hu-int-17"

    # Verify rollback successfully dropped new tables
    $outboxDropped = Invoke-Scalar "SELECT to_regclass('support.notification_outbox') IS NULL;"
    if ($outboxDropped -ne "t") { throw "Expected support.notification_outbox to be dropped by rollback." }

    $attemptsDropped = Invoke-Scalar "SELECT to_regclass('support.notification_delivery_attempts') IS NULL;"
    if ($attemptsDropped -ne "t") { throw "Expected support.notification_delivery_attempts to be dropped by rollback." }

    $templatesDropped = Invoke-Scalar "SELECT to_regclass('support.notification_templates') IS NULL;"
    if ($templatesDropped -ne "t") { throw "Expected support.notification_templates to be dropped by rollback." }

    # 5. Re-apply migrations so the database remains updated and ready
    Invoke-Checked { docker compose --env-file $EnvFile run --rm liquibase update } "re-apply liquibase update"

    Write-Host "HU-INT-17 Liquibase migration, outbox, delivery attempts, templates and rollback test passed successfully."
}
finally {
    # Keep container running
}
