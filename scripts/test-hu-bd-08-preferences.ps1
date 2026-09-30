param(
    [string]$HostName = $env:PGHOST,
    [string]$Port = $env:PGPORT,
    [string]$Database = $env:PGDATABASE,
    [string]$User = $env:PGUSER
)

if (-not $HostName) { $HostName = 'localhost' }
if (-not $Port) { $Port = '5432' }
if (-not $Database) { $Database = 'drivique' }
if (-not $User) { $User = 'postgres' }

$scriptPath = Join-Path $PSScriptRoot 'tests\test-hu-bd-08-preferences.sql'

Write-Host "Running HU-BD-08 Database Test Suite on ${Database}@${HostName}:${Port}..." -ForegroundColor Cyan

$env:PGCLIENTENCODING = 'UTF8'
& psql -h $HostName -p $Port -U $User -d $Database -v ON_ERROR_STOP=1 -f $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "HU-BD-08 Tests Passed Successfully!" -ForegroundColor Green
} else {
    Write-Host "HU-BD-08 Tests Failed!" -ForegroundColor Red
    exit 1
}
