[CmdletBinding()]
param(
    [ValidateSet("Start", "Stop", "Status")]
    [string]$Command = "Status",

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",

    [string]$Address = "127.0.0.1:50051"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$executable = Join-Path $repositoryRoot "build\windows-msvc-debug\services\orchestrator\$Configuration\twins-orchestrator.exe"
$runtimeRoot = Join-Path $repositoryRoot ".tools\runtime\state-stream"
$pidFile = Join-Path $runtimeRoot "server.pid"
$standardOutput = Join-Path $runtimeRoot "server.stdout.log"
$standardError = Join-Path $runtimeRoot "server.stderr.log"

function Get-StateServerProcess {
    if (-not (Test-Path -LiteralPath $pidFile)) {
        return $null
    }

    $processId = [int](Get-Content -LiteralPath $pidFile -Raw).Trim()
    $process = Get-CimInstance Win32_Process -Filter "ProcessId = $processId" -ErrorAction SilentlyContinue
    if ($null -eq $process) {
        Remove-Item -LiteralPath $pidFile -Force
        return $null
    }

    if ([System.IO.Path]::GetFullPath($process.ExecutablePath) -ne [System.IO.Path]::GetFullPath($executable)) {
        throw "PID $processId belongs to a different executable; refusing to manage it."
    }

    return $process
}

function Start-StateServer {
    $existingProcess = Get-StateServerProcess
    if ($null -ne $existingProcess) {
        Write-Output "Twins state stream is already running with PID $($existingProcess.ProcessId)."
        return
    }
    if (-not (Test-Path -LiteralPath $executable)) {
        throw "The orchestrator is not built at '$executable'. Build the $Configuration configuration first."
    }

    New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
    Remove-Item -LiteralPath $standardOutput, $standardError -Force -ErrorAction SilentlyContinue
    $process = Start-Process -FilePath $executable -ArgumentList @(
        "--serve-state-fixture",
        $Address
    ) -RedirectStandardOutput $standardOutput -RedirectStandardError $standardError -WindowStyle Hidden -PassThru
    Set-Content -LiteralPath $pidFile -Value $process.Id -NoNewline

    $ready = $false
    for ($attempt = 0; $attempt -lt 100; ++$attempt) {
        if ($process.HasExited) {
            $errorOutput = if (Test-Path -LiteralPath $standardError) {
                (Get-Content -LiteralPath $standardError -Raw).Trim()
            }
            else {
                "no error output"
            }
            Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
            throw "The state stream exited before becoming ready: $errorOutput"
        }
        if ((Test-Path -LiteralPath $standardOutput) -and
            (Select-String -LiteralPath $standardOutput -SimpleMatch "TWINS_STATE_SERVER_READY" -Quiet)) {
            $ready = $true
            break
        }
        Start-Sleep -Milliseconds 100
    }

    if (-not $ready) {
        Stop-Process -Id $process.Id -Force
        Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
        throw "The state stream did not report readiness within 10 seconds."
    }

    Write-Output "Twins state stream started with PID $($process.Id) on $Address."
}

function Stop-StateServer {
    $process = Get-StateServerProcess
    if ($null -eq $process) {
        Write-Output "Twins state stream is not running."
        return
    }

    Stop-Process -Id $process.ProcessId
    Wait-Process -Id $process.ProcessId -Timeout 5 -ErrorAction SilentlyContinue
    if (Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue) {
        Stop-Process -Id $process.ProcessId -Force
    }
    Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
    Write-Output "Twins state stream stopped."
}

function Show-StateServerStatus {
    $process = Get-StateServerProcess
    if ($null -eq $process) {
        Write-Output "Twins state stream: stopped"
        return
    }

    Write-Output "Twins state stream: running (PID $($process.ProcessId), address $Address)"
}

switch ($Command) {
    "Start" { Start-StateServer }
    "Stop" { Stop-StateServer }
    "Status" { Show-StateServerStatus }
}
