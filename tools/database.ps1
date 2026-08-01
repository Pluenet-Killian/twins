[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Up", "Stop", "Migrate", "Status")]
    [string]$Command
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $repositoryRoot "infra\compose\compose.yaml"
$migrationsDirectory = Join-Path $repositoryRoot "database\migrations"

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
