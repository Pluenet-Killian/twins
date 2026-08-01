[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CMakeArguments
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$cmakeExecutable = Join-Path $repositoryRoot ".tools\cmake-4.3.4-windows-x86_64\bin\cmake.exe"

if (-not (Test-Path $cmakeExecutable)) {
    throw "Pinned CMake is missing. Run tools/bootstrap-cmake.ps1 first."
}

& $cmakeExecutable @CMakeArguments
exit $LASTEXITCODE
