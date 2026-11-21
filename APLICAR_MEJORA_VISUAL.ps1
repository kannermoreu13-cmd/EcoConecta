$ErrorActionPreference = "Stop"
$container = "ecoconecta-web-1"
$root = $PSScriptRoot
$assets = @(
    @{ Source = (Join-Path $root "app\static\index.html"); Target = "/srv/ecoconecta/app/static/index.html" },
    @{ Source = (Join-Path $root "app\static\styles.css"); Target = "/srv/ecoconecta/app/static/styles.css" },
    @{ Source = (Join-Path $root "app\static\img\hero-landscape-photo.png"); Target = "/srv/ecoconecta/app/static/img/hero-landscape-photo.png" }
)
Write-Host "`nECOCONECTA 2.0.2 - INSTALACION VISUAL COMPLETA" -ForegroundColor Cyan
$inspect = docker inspect $container 2>$null
if ($LASTEXITCODE -ne 0 -or !$inspect) { throw "No se encuentra $container. Inicia Docker Desktop y EcoConecta." }
$info = @($inspect | ConvertFrom-Json)[0]
if ($info.State.Status -ne "running") { throw "El contenedor web no esta activo." }
foreach ($asset in $assets) {
    if (!(Test-Path -LiteralPath $asset.Source)) { throw "Falta el archivo $($asset.Source)" }
}
# Respaldar los tres archivos actuales dentro de Descargas.
$backupDir = Join-Path $env:USERPROFILE ("Downloads\EcoConecta_respaldo_visual_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$i = 0
foreach ($asset in $assets) {
    $i++
    $backup = Join-Path $backupDir ("asset_" + $i + "_" + [IO.Path]::GetFileName($asset.Source))
    docker cp "${container}:$($asset.Target)" $backup 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Warning "No existia copia previa de $($asset.Target)." }
}
# Instalar HTML, CSS y fotografía; no toca API, PostgreSQL ni volúmenes.
foreach ($asset in $assets) {
    docker cp $asset.Source "${container}:$($asset.Target)"
    if ($LASTEXITCODE -ne 0) { throw "No se pudo instalar $($asset.Target)" }
}
docker restart $container | Out-Null
if ($LASTEXITCODE -ne 0) { throw "No se pudo reiniciar el servicio web." }
Start-Sleep -Seconds 6
try {
    $r = Invoke-WebRequest "http://localhost:8000/" -UseBasicParsing -TimeoutSec 20
    if ($r.StatusCode -ne 200) { throw "HTTP $($r.StatusCode)" }
    $s = Invoke-WebRequest "http://localhost:8000/static/styles.css?v=2.0.2" -UseBasicParsing -TimeoutSec 20
    if ($s.StatusCode -ne 200 -or $s.Content -notmatch "hero-landscape-photo") { throw "No se detectó el CSS nuevo." }
    $im = Invoke-WebRequest "http://localhost:8000/static/img/hero-landscape-photo.png" -UseBasicParsing -TimeoutSec 20
    if ($im.StatusCode -ne 200) { throw "No se pudo servir la fotografía." }
    Write-Host "`nINSTALACION VISUAL COMPLETA: OK" -ForegroundColor Green
    Write-Host "Pagina: http://localhost:8000" -ForegroundColor Cyan
    Write-Host "Respaldo: $backupDir"
    Write-Host "Presiona Ctrl+Shift+R en el navegador."
} catch {
    Write-Warning "Archivos copiados y contenedor reiniciado, pero la prueba HTTP no terminó: $($_.Exception.Message)"
    Write-Host "Revisa http://localhost:8000 y presiona Ctrl+Shift+R."
}
