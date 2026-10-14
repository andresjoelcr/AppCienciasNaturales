<#
.SYNOPSIS
    Lanza la app inyectando SIEMPRE las variables de .env.

.DESCRIPTION
    Flutter resuelve String.fromEnvironment en tiempo de compilacion, asi que
    arrancar con `flutter run` a secas deja GROQ_API_KEY vacia y tanto el chat
    como el escaner responden "no esta configurado". Este script pasa
    --dart-define-from-file=.env, que es la unica forma de que la clave llegue
    al binario sin publicarla como asset.

    Las claves de Firebase no se tocan: google-services.json se empaqueta solo.

.EXAMPLE
    .\tool\run.ps1
    .\tool\run.ps1 -Device 23090RA98G
    .\tool\run.ps1 -BuildApk
    .\tool\run.ps1 -BuildApk -Release
#>
[CmdletBinding()]
param(
    [string] $Device,
    [switch] $Profile,
    [switch] $Release,
    [switch] $BuildApk
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root '.env'

if (-not (Test-Path -LiteralPath $envFile)) {
    throw "No se encontro .env. Copia .env.example a .env y completa GROQ_API_KEY."
}

$defines = @{}
foreach ($line in Get-Content -LiteralPath $envFile) {
    $trimmed = $line.Trim()
    if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }
    $parts = $trimmed.Split('=', 2)
    if ($parts.Count -ne 2) { continue }
    $defines[$parts[0].Trim()] = $parts[1].Trim().Trim('"').Trim("'")
}

# Valida lo que la app necesita para funcionar. Sin vision no hay escaner.
$requeridas = @('GROQ_API_KEY', 'GROQ_MODEL', 'GROQ_VISION_MODEL')
$ejemplos = @('tu_clave_de_groq', 'tu_clave_de_gemini', 'TU_API_KEY_AQUI')
foreach ($clave in $requeridas) {
    if (-not $defines.ContainsKey($clave) -or
        $defines[$clave] -eq '' -or
        $ejemplos -contains $defines[$clave]) {
        throw "$clave vacio o sin completar en .env. La app no funcionara."
    }
}

Write-Host "GROQ_API_KEY       = $($defines['GROQ_API_KEY'].Substring(0, 7))... (cargada)"
Write-Host "GROQ_MODEL         = $($defines['GROQ_MODEL'])"
Write-Host "GROQ_VISION_MODEL  = $($defines['GROQ_VISION_MODEL'])"

# Mantiene assets/.env al dia para que F5 y flutter run a secas tambien funcionen.
& (Join-Path $PSScriptRoot 'sync_env.ps1') | Out-Null

Push-Location $root
try {
    if ($BuildApk) {
        $args = @('build', 'apk', '--dart-define-from-file=.env')
        if ($Release) { $args += '--release' }
        & flutter @args
    } else {
        $flutterArgs = @('run', '--dart-define-from-file=.env')
        if ($Device) { $flutterArgs += @('-d', $Device) }
        if ($Profile) { $flutterArgs += '--profile' }
        & flutter @flutterArgs
    }
} finally {
    Pop-Location
}
