[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$failures = [System.Collections.Generic.List[string]]::new()

function Test-ExactVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Expected,
        [Parameter(Mandatory = $true)]
        [scriptblock]$ReadVersion
    )

    try {
        $actual = (& $ReadVersion | Out-String).Trim()
        if ($actual -eq $Expected) {
            Write-Host "[ok] $Name $actual"
            return
        }

        Write-Host "[mismatch] $Name expected $Expected, found $actual"
        $failures.Add("$Name expected $Expected, found $actual")
    }
    catch {
        Write-Host "[missing] $Name expected $Expected"
        $failures.Add("$Name is missing: $($_.Exception.Message)")
    }
}

Test-ExactVersion "Git" "2.52.0.windows.1" {
    (git --version) -replace '^git version ', ''
}

Test-ExactVersion "Git LFS" "3.7.1" {
    if ((git lfs version) -notmatch '^git-lfs/(?<version>[^ ]+)') {
        throw "Unable to parse Git LFS version."
    }
    $Matches.version
}

Test-ExactVersion "CMake" "4.3.4" {
    $repositoryRoot = Split-Path -Parent $PSScriptRoot
    $cmakeExecutable = Join-Path $repositoryRoot ".tools\cmake-4.3.4-windows-x86_64\bin\cmake.exe"
    if ((& $cmakeExecutable --version | Select-Object -First 1) -notmatch '^cmake version (?<version>.+)$') {
        throw "Unable to parse CMake version."
    }
    $Matches.version
}

Test-ExactVersion "uv" "0.12.1" {
    if ((uv --version) -notmatch '^uv (?<version>[^ ]+)') {
        throw "Unable to parse uv version."
    }
    $Matches.version
}

Test-ExactVersion "Python" "3.13.14" {
    (uv run --frozen python --version) -replace '^Python ', ''
}

Test-ExactVersion "Node.js" "24.18.0" {
    (node --version).TrimStart('v')
}

Test-ExactVersion "pnpm" "11.4.0" {
    corepack pnpm --version
}

Test-ExactVersion "Buf" "1.72.0" {
    buf --version
}

Test-ExactVersion "dbmate" "2.34.1" {
    if ((dbmate --version) -notmatch '(?<version>\d+\.\d+\.\d+)') {
        throw "Unable to parse dbmate version."
    }
    $Matches.version
}

Test-ExactVersion "Docker Engine" "29.2.1" {
    docker version --format '{{.Client.Version}}'
}

Test-ExactVersion "Docker Compose" "5.0.2" {
    docker compose version --short
}

$windowsSdkPath = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10\Include\10.0.26100.0"
if (Test-Path $windowsSdkPath) {
    Write-Host "[ok] Windows SDK 10.0.26100.0"
}
else {
    Write-Host "[missing] Windows SDK 10.0.26100.0"
    $failures.Add("Windows SDK 10.0.26100.0 is missing")
}

$vswherePath = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswherePath) {
    Test-ExactVersion "Visual Studio Build Tools" "17.14.37516.0" {
        & $vswherePath `
            -latest `
            -products Microsoft.VisualStudio.Product.BuildTools `
            -version '[17.0,18.0)' `
            -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            -property installationVersion
    }
}
else {
    Write-Host "[missing] Visual Studio Build Tools 17.14.37516.0"
    $failures.Add("Visual Studio Build Tools is missing")
}

if ($failures.Count -gt 0) {
    Write-Error ("Toolchain check failed:`n- " + ($failures -join "`n- "))
    exit 1
}

Write-Host "All selected foundation tools match the baseline."
