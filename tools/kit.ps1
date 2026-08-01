[CmdletBinding()]
param(
    [ValidateSet("Bootstrap", "Build", "Validate", "Launch", "Status")]
    [string]$Command = "Status",

    [ValidateSet("debug", "release")]
    [string]$Configuration = "release",

    [switch]$AcceptNvidiaTerms
)

$ErrorActionPreference = "Stop"

$kitTemplateRepository = "https://github.com/NVIDIA-Omniverse/kit-app-template.git"
$kitTemplateCommit = "483e364a4176f102f2d3c3aaf9f301a103d61d69"
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$toolsRoot = Join-Path $repositoryRoot ".tools"
$kitTemplateRoot = Join-Path $toolsRoot "kit-app-template"
$eulaBreadcrumb = Join-Path $kitTemplateRoot ".omniverse_eula_accepted.txt"
$playbackFile = Join-Path $repositoryRoot "apps\kit\template-playback.toml"
$canonicalApplication = Join-Path $repositoryRoot "apps\kit\source\apps\twins.engineering.kit"
$canonicalExtensions = Join-Path $repositoryRoot "apps\kit\source\extensions"
$generatedApplication = Join-Path $kitTemplateRoot "source\apps\twins.engineering.kit"
$generatedExtensions = Join-Path $kitTemplateRoot "source\extensions"
$referenceStage = Join-Path $repositoryRoot "assets\usd\reference-rack.usda"

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Executable,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @()
    )

    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Executable $($Arguments -join ' ')"
    }
}

function Assert-KitTemplateCheckout {
    if (-not (Test-Path -LiteralPath (Join-Path $kitTemplateRoot ".git"))) {
        New-Item -ItemType Directory -Path $toolsRoot -Force | Out-Null
        Invoke-Checked -Executable "git" -Arguments @(
            "clone",
            "--filter=blob:none",
            "--no-checkout",
            $kitTemplateRepository,
            $kitTemplateRoot
        )
        Invoke-Checked -Executable "git" -Arguments @(
            "-C",
            $kitTemplateRoot,
            "checkout",
            "--detach",
            $kitTemplateCommit
        )
    }

    $actualCommit = (& git -C $kitTemplateRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $actualCommit -ne $kitTemplateCommit) {
        throw "Kit App Template must be checked out at $kitTemplateCommit; found '$actualCommit'."
    }
}

function Assert-NvidiaTermsAccepted {
    if (Test-Path -LiteralPath $eulaBreadcrumb) {
        return
    }

    if (-not $AcceptNvidiaTerms) {
        throw "NVIDIA terms are not accepted locally. Read the NVIDIA Software License Agreement and Omniverse Product-Specific Terms, then rerun with -AcceptNvidiaTerms if you accept them."
    }

    New-Item -ItemType File -Path $eulaBreadcrumb -Force | Out-Null
}

function Sync-KitApplication {
    Assert-KitTemplateCheckout
    Assert-NvidiaTermsAccepted

    if (-not (Test-Path -LiteralPath $generatedApplication)) {
        Push-Location $kitTemplateRoot
        try {
            Invoke-Checked -Executable (Join-Path $kitTemplateRoot "repo.bat") -Arguments @(
                "template",
                "replay",
                $playbackFile
            )
        }
        finally {
            Pop-Location
        }
    }

    $generatedApplicationDirectory = Split-Path -Parent $generatedApplication
    New-Item -ItemType Directory -Path $generatedApplicationDirectory -Force | Out-Null
    Copy-Item -LiteralPath $canonicalApplication -Destination $generatedApplication -Force
    New-Item -ItemType Directory -Path $generatedExtensions -Force | Out-Null
    Copy-Item -Path (Join-Path $canonicalExtensions "*") -Destination $generatedExtensions -Recurse -Force
}

function Build-KitApplication {
    Sync-KitApplication

    Push-Location $kitTemplateRoot
    try {
        Invoke-Checked -Executable (Join-Path $kitTemplateRoot "repo.bat") -Arguments @(
            "build",
            "--config",
            $Configuration
        )
    }
    finally {
        Pop-Location
    }
}

function Launch-KitApplication {
    Sync-KitApplication

    $buildRoot = Join-Path $kitTemplateRoot "_build\windows-x86_64\$Configuration"
    $launcher = Join-Path $buildRoot "twins.engineering.kit.bat"
    if (-not (Test-Path -LiteralPath $launcher)) {
        throw "The Kit application is not built. Run '.\tools\kit.ps1 -Command Build -Configuration $Configuration' first."
    }

    $resolvedStage = (Resolve-Path -LiteralPath $referenceStage).Path
    $stageSetting = $resolvedStage.Replace("\", "/")
    $process = Start-Process -FilePath $launcher -ArgumentList @(
        "--portable-root",
        "`"$buildRoot`"",
        "--/app/enableStdoutOutput=1",
        "--/log/flushStandardStreamOutput=1",
        "--/exts/twins.engineering.setup/stage_path=`"$stageSetting`""
    ) -PassThru
    Write-Output "Twins Engineering started with PID $($process.Id) and stage '$resolvedStage'."
}

function Validate-KitStage {
    Sync-KitApplication

    $buildRoot = Join-Path $kitTemplateRoot "_build\windows-x86_64\$Configuration"
    $kitPython = Join-Path $buildRoot "kit\python.bat"
    $usdLibrariesLink = Join-Path $buildRoot "extsbuild\omni.usd.libs"
    if (-not (Test-Path -LiteralPath $kitPython) -or -not (Test-Path -LiteralPath $usdLibrariesLink)) {
        throw "The Kit application is not built. Run '.\tools\kit.ps1 -Command Build -Configuration $Configuration' first."
    }

    $usdLibrariesRoot = (Get-Item -LiteralPath $usdLibrariesLink).Target
    $validator = Join-Path $repositoryRoot "tools\validate-usd.py"
    $previousPythonPath = $env:PYTHONPATH
    $previousPath = $env:Path
    try {
        $env:PYTHONPATH = $usdLibrariesRoot
        $env:Path = (Join-Path $usdLibrariesRoot "bin") + ";" + $env:Path
        Invoke-Checked -Executable $kitPython -Arguments @(
            $validator,
            $referenceStage,
            "/World/Assets/ReferenceRackA01",
            "00000000-0000-4000-8000-000000000001",
            "urn:twins:asset-type:compute-rack"
        )
    }
    finally {
        $env:PYTHONPATH = $previousPythonPath
        $env:Path = $previousPath
    }
}

function Show-KitStatus {
    if (-not (Test-Path -LiteralPath (Join-Path $kitTemplateRoot ".git"))) {
        Write-Output "Kit App Template: not bootstrapped"
        return
    }

    $actualCommit = (& git -C $kitTemplateRoot rev-parse HEAD).Trim()
    $buildVersionFile = Join-Path $kitTemplateRoot "_build\windows-x86_64\$Configuration\VERSION"
    $buildVersion = if (Test-Path -LiteralPath $buildVersionFile) {
        (Get-Content -LiteralPath $buildVersionFile -Raw).Trim()
    }
    else {
        "not built"
    }

    Write-Output "Kit App Template commit: $actualCommit"
    Write-Output "NVIDIA terms accepted locally: $(Test-Path -LiteralPath $eulaBreadcrumb)"
    Write-Output "Twins Engineering build: $buildVersion"
}

switch ($Command) {
    "Bootstrap" { Sync-KitApplication }
    "Build" { Build-KitApplication }
    "Validate" { Validate-KitStage }
    "Launch" { Launch-KitApplication }
    "Status" { Show-KitStatus }
}
