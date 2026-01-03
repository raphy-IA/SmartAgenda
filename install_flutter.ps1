# Script d'installation automatique de Flutter pour Windows
# Version avec barre de progression (BITS)

$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.2-stable.zip"
$dest = "C:\src\flutter.zip"
$installDir = "C:\src"
$flutterBin = "C:\src\flutter\bin"

Write-Host "1. PREPARATION..." -ForegroundColor Cyan
if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }

Write-Host "2. TELECHARGEMENT (avec progression)..." -ForegroundColor Cyan
# Utilisation de BITS pour voir l'avancement
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $dest -DisplayName "Flutter Download" -Priority Foreground

Write-Host "3. EXTRACTION (Patientez)..." -ForegroundColor Cyan
Expand-Archive -Path $dest -DestinationPath $installDir -Force

Write-Host "4. CONFIGURATION PATH..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$flutterBin*") {
    $newPath = "$currentPath;$flutterBin"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "PATH mis a jour." -ForegroundColor Green
}
else {
    Write-Host "Flutter deja dans le PATH."
}

Remove-Item $dest -Force
Write-Host "TERMINE ! Redemarrez votre terminal." -ForegroundColor Green
