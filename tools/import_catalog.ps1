# Cravvy — generate, validate, and import VN recipe catalog (Windows)
# Usage: .\tools\import_catalog.ps1
#        .\tools\import_catalog.ps1 -SkipImport
#        .\tools\import_catalog.ps1 -DryRunOnly

param(
    [switch]$SkipImport,
    [switch]$DryRunOnly
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Find-PythonExe {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    foreach ($name in @("python", "python3")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd -and $cmd.Source -notmatch "WindowsApps") {
            return $cmd.Source
        }
    }
    return $null
}

function Invoke-Python {
    param(
        [string]$Exe,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$ScriptArgs
    )
    & $Exe @ScriptArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $Exe $($ScriptArgs -join ' ')"
    }
}

$python = Find-PythonExe
if (-not $python) {
    Write-Host "ERROR: Python not found. Install Python 3.11+ and add to PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Using: $python" -ForegroundColor Cyan

Write-Host "`n[1/4] pip install requirements..." -ForegroundColor Green
Invoke-Python $python -m pip install -q -r tools/requirements.txt

Write-Host "`n[2/4] generate_vn_seed.py..." -ForegroundColor Green
Invoke-Python $python tools/generate_vn_seed.py

Write-Host "`n[3/4] validate_seed.py..." -ForegroundColor Green
Invoke-Python $python tools/validate_seed.py

if ($DryRunOnly) {
    Write-Host "`n[4/4] import dry-run..." -ForegroundColor Green
    Invoke-Python $python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json --dry-run
    Write-Host "`nDone (dry-run only)." -ForegroundColor Cyan
    exit 0
}

if ($SkipImport) {
    Write-Host "`nSkipped import (-SkipImport)." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path "tools/.env")) {
    Write-Host "WARN: tools/.env missing. Copy tools/.env.example and set SUPABASE_* keys." -ForegroundColor Yellow
    Write-Host "Running dry-run instead of live import." -ForegroundColor Yellow
    Invoke-Python $python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json --dry-run
    exit 0
}

Write-Host "`n[4/4] import_recipes.py (live upsert)..." -ForegroundColor Green
Invoke-Python $python tools/import_recipes.py --file data/seeds/vietnamese_recipes.json

Write-Host "`nCatalog import complete." -ForegroundColor Cyan
