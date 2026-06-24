#Requires -Version 5.1
<#
.SYNOPSIS
    PrusaSlicer Windows setup and build script (PowerShell wrapper around build_win.bat).

.DESCRIPTION
    Checks prerequisites, then builds PrusaSlicer dependencies and application.
    On first run: builds everything. On subsequent runs: incremental app-only build.

.PARAMETER DepsDir
    Directory for compiled dependencies. Default: ..\PrusaSlicer-deps

.PARAMETER Config
    Build configuration: Release, Debug, or RelWithDebInfo. Default: RelWithDebInfo

.PARAMETER Steps
    Build steps: all, all-dirty, app, app-dirty, deps, deps-dirty. Default: app-dirty

.PARAMETER Run
    What to run after build: console, window, viewer, ide, none. Default: none

.EXAMPLE
    # First-time build:
    .\setup.ps1

.EXAMPLE
    # Clean build with custom deps dir:
    .\setup.ps1 -DepsDir "D:\PrusaSlicer-deps" -Steps all

.EXAMPLE
    # Quick incremental build and run:
    .\setup.ps1 -Steps app-dirty -Run console
#>

[CmdletBinding()]
param(
    [string]$DepsDir = "..\PrusaSlicer-deps",
    [ValidateSet("Release","Debug","RelWithDebInfo")]
    [string]$Config = "RelWithDebInfo",
    [ValidateSet("all","all-dirty","app","app-dirty","deps","deps-dirty")]
    [string]$Steps = "app-dirty",
    [ValidateSet("console","window","viewer","ide","none")]
    [string]$Run = "none"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step([string]$msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Fail([string]$msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

Write-Step "Checking prerequisites"

# Check CMake
$cmake = Get-Command cmake -ErrorAction SilentlyContinue
if (-not $cmake) {
    Write-Fail "CMake not found. Install from https://cmake.org/download/ and add to PATH."
}
Write-Host "  cmake: $((cmake --version 2>&1)[0])"

# Check git
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Fail "git not found. Install from https://git-scm.com/download/win."
}
Write-Host "  git: $((git --version 2>&1))"

# Check Visual Studio (via vswhere)
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    Write-Fail "Visual Studio 2019 or 2022 not found. Install from https://visualstudio.microsoft.com/."
}
$vs = & $vswhere -latest -property displayName 2>&1
Write-Host "  Visual Studio: $vs"

Write-Step "Prerequisites satisfied"

# Resolve deps dir to absolute path
$DepsDir = [IO.Path]::GetFullPath((Join-Path (Get-Location) $DepsDir))
Write-Host "  Dependencies dir: $DepsDir"
Write-Host "  Build config:     $Config"
Write-Host "  Build steps:      $Steps"

Write-Step "Starting build (this may take a long time on first run)"

$batArgs = "-d=`"$DepsDir`" -s=$Steps -c=$Config -r=$Run"
Write-Host "  Running: build_win.bat $batArgs`n"

cmd /c "build_win.bat $batArgs"
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Build failed with exit code $LASTEXITCODE. Check output above for errors.`nTip: run 'build_win.bat -?' for all options."
}

Write-Step "Build succeeded!"
Write-Host "  Run the app with: .\run.ps1"
Write-Host "  Or open the IDE:  .\setup.ps1 -Steps app-dirty -Run ide"
