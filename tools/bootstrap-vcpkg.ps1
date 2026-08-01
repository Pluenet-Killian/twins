[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$toolsDirectory = Join-Path $repositoryRoot ".tools"
$vcpkgDirectory = Join-Path $toolsDirectory "vcpkg"
$expectedCommit = "c76c06644034521fb761a39f8f52d8e87d1103d5"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required to bootstrap vcpkg."
}

New-Item -ItemType Directory -Force $toolsDirectory | Out-Null

if (-not (Test-Path (Join-Path $vcpkgDirectory ".git"))) {
    if (Test-Path $vcpkgDirectory) {
        throw "The vcpkg target exists but is not a Git repository: $vcpkgDirectory"
    }

    git clone --filter=blob:none --no-checkout https://github.com/microsoft/vcpkg.git $vcpkgDirectory
}

$currentCommit = git -C $vcpkgDirectory rev-parse HEAD 2>$null
if ($LASTEXITCODE -ne 0 -or $currentCommit -ne $expectedCommit) {
    git -C $vcpkgDirectory fetch origin $expectedCommit --depth 1
    git -C $vcpkgDirectory checkout --detach $expectedCommit
}

$bootstrapScript = Join-Path $vcpkgDirectory "bootstrap-vcpkg.bat"
if (-not (Test-Path $bootstrapScript)) {
    throw "The pinned vcpkg checkout does not contain bootstrap-vcpkg.bat."
}

& $bootstrapScript -disableMetrics
if ($LASTEXITCODE -ne 0) {
    throw "vcpkg bootstrap failed with exit code $LASTEXITCODE."
}

& (Join-Path $vcpkgDirectory "vcpkg.exe") version
