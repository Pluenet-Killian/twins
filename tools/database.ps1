[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Up", "Stop", "Migrate", "Seed", "Status")]
    [string]$Command
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $repositoryRoot "infra\compose\compose.yaml"
$migrationsDirectory = Join-Path $repositoryRoot "database\migrations"
$referenceSeed = Join-Path $repositoryRoot "database\seeds\reference.sql"

function Assert-CommandExists([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is required for database command $Command."
    }
}

switch ($Command) {
    "Up" {
        Assert-CommandExists "docker"
        docker compose --file $composeFile up --detach --wait database
    }
    "Stop" {
        Assert-CommandExists "docker"
        docker compose --file $composeFile stop database
    }
    "Migrate" {
        Assert-CommandExists "dbmate"
        if (-not $env:DATABASE_URL) {
            throw "DATABASE_URL must be set before running migrations."
        }
        dbmate --migrations-dir $migrationsDirectory --no-dump-schema up
    }
    "Seed" {
        Assert-CommandExists "docker"
        if (-not $env:TWINS_POSTGRES_DB -or -not $env:TWINS_POSTGRES_USER) {
            throw "TWINS_POSTGRES_DB and TWINS_POSTGRES_USER must be set before seeding."
        }
        if (-not (Test-Path $referenceSeed)) {
            throw "Reference seed not found: $referenceSeed"
        }
        Get-Content -Raw $referenceSeed | docker compose --file $composeFile exec -T database `
            psql -v ON_ERROR_STOP=1 -U $env:TWINS_POSTGRES_USER -d $env:TWINS_POSTGRES_DB
    }
    "Status" {
        Assert-CommandExists "dbmate"
        if (-not $env:DATABASE_URL) {
            throw "DATABASE_URL must be set before checking migration status."
        }
        dbmate --migrations-dir $migrationsDirectory status
    }
}

if ($LASTEXITCODE -ne 0) {
    throw "Database command $Command failed with exit code $LASTEXITCODE."
}
