<#
.SYNOPSIS
    Copia .env a assets/groq.env para empaquetarlo dentro de la app.

.DESCRIPTION
    Flutter solo resuelve String.fromEnvironment al compilar, asi que sin
    --dart-define-from-file=.env la clave de Groq llega vacia. Empaquetando el
    .env como asset la app funciona siempre: con F5, con `flutter run` a secas y
    en un APK ya instalado.

    El destino NO empieza por punto a proposito: Flutter descarta del paquete
    cualquier archivo cuyo nombre empieza por '.', aunque se declare en el
    pubspec.

    Se ejecuta automaticamente desde tool/run.ps1. Si editas .env a mano, vuelve
    a ejecutar este script o usa run.ps1.

    AVISO DE SEGURIDAD: la clave queda legible dentro del APK con cualquier
    extractor. Para produccion, las llamadas a Groq deben pasar por un backend.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$origen = Join-Path $root '.env'
$destino = Join-Path $root 'assets\groq.env'

if (-not (Test-Path -LiteralPath $origen)) {
    throw "No se encontro .env. Copia .env.example a .env y completa GROQ_API_KEY."
}

$destinoDir = Split-Path -Parent $destino
if (-not (Test-Path -LiteralPath $destinoDir)) {
    New-Item -ItemType Directory -Path $destinoDir | Out-Null
}

$contenido = Get-Content -LiteralPath $origen -Raw
[System.IO.File]::WriteAllText($destino, $contenido, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "assets/groq.env actualizado desde .env"
