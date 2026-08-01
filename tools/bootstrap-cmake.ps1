[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$version = "4.3.4"
$archiveName = "cmake-$version-windows-x86_64.zip"
$expectedSha256 = "86e5fcafb38bdf58346a78b187c7b6b4f252ae5242cffe24c463a92bbd2e77d1"
$downloadUrl = "https://github.com/Kitware/CMake/releases/download/v$version/$archiveName"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$toolsDirectory = Join-Path $repositoryRoot ".tools"
$cmakeDirectory = Join-Path $toolsDirectory "cmake-$version-windows-x86_64"
$cmakeExecutable = Join-Path $cmakeDirectory "bin\cmake.exe"
$archivePath = Join-Path $env:TEMP "twins-$archiveName"

if (Test-Path $cmakeExecutable) {
    & $cmakeExecutable --version
    exit $LASTEXITCODE
}

if (Test-Path $cmakeDirectory) {
    throw "The CMake target exists but is incomplete: $cmakeDirectory"
}

New-Item -ItemType Directory -Force $toolsDirectory | Out-Null

if (-not (Test-Path $archivePath)) {
    Invoke-WebRequest -UseBasicParsing $downloadUrl -OutFile $archivePath
}

$actualSha256 = (Get-FileHash -Algorithm SHA256 $archivePath).Hash.ToLowerInvariant()
if ($actualSha256 -ne $expectedSha256) {
    throw "CMake archive checksum mismatch. Expected $expectedSha256, found $actualSha256."
}

Expand-Archive -LiteralPath $archivePath -DestinationPath $toolsDirectory

if (-not (Test-Path $cmakeExecutable)) {
    throw "CMake extraction did not produce the expected executable."
}

& $cmakeExecutable --version
