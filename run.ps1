#Requires -Version 5.1
<#
.SYNOPSIS
    Launches a built PrusaSlicer executable.

.PARAMETER Mode
    Which binary to run: slicer (GUI), console (CLI), or viewer (G-code viewer). Default: slicer

.PARAMETER BuildDir
    Build output directory. Default: build

.EXAMPLE
    .\run.ps1
    .\run.ps1 -Mode console
    .\run.ps1 -Mode viewer
#>

[CmdletBinding()]
param(
    [ValidateSet("slicer","console","viewer")]
    [string]$Mode = "slicer",
    [string]$BuildDir = "build"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Fail([string]$msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

$nameMap = @{
    "slicer"  = "prusa-slicer.exe"
    "console" = "prusa-slicer-console.exe"
    "viewer"  = "prusa-gcodeviewer.exe"
}

$exeName = $nameMap[$Mode]

# Search common output locations
$searchPaths = @(
    "$BuildDir\src\$exeName",
    "$BuildDir\src\RelWithDebInfo\$exeName",
    "$BuildDir\src\Release\$exeName",
    "$BuildDir\src\Debug\$exeName"
)

$found = $null
foreach ($p in $searchPaths) {
    if (Test-Path $p) { $found = (Resolve-Path $p).Path; break }
}

if (-not $found) {
    Write-Fail "$exeName not found. Run '.\setup.ps1' to build first.`nSearched: $($searchPaths -join ', ')"
}

Write-Host "Launching: $found" -ForegroundColor Cyan
& $found
