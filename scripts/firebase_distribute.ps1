# Upload release APK to Firebase App Distribution
# Prerequisite: npm i -g firebase-tools; firebase login; App Distribution enabled in Firebase console
#
# Usage:
#   flutter build apk --release
#   .\scripts\firebase_distribute.ps1 -AppId "1:xxx:android:yyy" -Groups "testers" -Notes "MVP 1.0.0"

param(
  [Parameter(Mandatory = $true)]
  [string]$AppId,

  [string]$Groups = "testers",
  [string]$Notes = "Cravvy MVP build",
  [string]$ApkPath = "build\app\outputs\flutter-apk\app-release.apk"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

if (-not (Test-Path $ApkPath)) {
  Write-Host "APK not found: $ApkPath" -ForegroundColor Red
  Write-Host "Run first: flutter build apk --release"
  exit 1
}

$size = [math]::Round((Get-Item $ApkPath).Length / 1MB, 1)
Write-Host "Distributing $ApkPath ($size MB) to group '$Groups'..." -ForegroundColor Cyan

firebase appdistribution:distribute $ApkPath `
  --app $AppId `
  --groups $Groups `
  --release-notes $Notes

if ($LASTEXITCODE -eq 0) {
  Write-Host "`nDone. Testers will receive email / in-app invite from Firebase." -ForegroundColor Green
}
