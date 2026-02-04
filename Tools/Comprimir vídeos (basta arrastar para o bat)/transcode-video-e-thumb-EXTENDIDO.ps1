param (
    [string]$inputFile = "",
    [string]$startTime = "",
    [string]$endTime   = "",
    [string]$caso      = "",
    [int]$indice       = 1,
    [int]$quiet        = 1,
    [string]$reduzirThumbs = "N",
    [string]$apagarLogs = "S",
    [string]$resizeThumbs = "N",
    [int]$resizePercent = 100,
    [string]$compressVideo = "N",
    [string]$compressAudio = "N",
    [string]$resizeVideo = "N",
    [int]$resizeVideoPercent = 100,
    [int]$taxaQuadros = 3
)

if ($caso) {
    $outDir = "D:\Casos\$caso\Multi\Videos"
} else {
    $outDir = "$env:USERPROFILE\Downloads"
}
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$base     = "Video$indice"
$videoOut = Join-Path $outDir "$base.mp4"
$thumbOut = Join-Path $outDir "VideoThumb${indice}.jpg"
$logFile  = Join-Path $outDir "$base.log"
$captionFile = Join-Path $outDir "VideoCaption${indice}.txt"

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ffmpeg não encontrado no PATH." -ForegroundColor Red
    exit 1
}

Write-Host "`n🎞️ Processando vídeo #${indice} - $inputFile" -ForegroundColor Cyan

# Apagar arquivos de destino anteriores se existirem
if (Test-Path $videoOut) { Remove-Item $videoOut -Force }
if (Test-Path $thumbOut) { Remove-Item $thumbOut -Force }
if (Test-Path $captionFile) { Remove-Item $captionFile -Force }
if (Test-Path $logFile) { Remove-Item $logFile -Force }

$tmpExt = [IO.Path]::GetExtension($inputFile)
$tmpInput = Join-Path $env:TEMP "input_tmp_${indice}${tmpExt}"
Copy-Item -LiteralPath $inputFile -Destination $tmpInput -Force

$cmd1 = @()

# Se início informado, adiciona o -ss antes do -i (mais eficiente e exato)
if ($startTime -ne "") {
    $cmd1 += "-ss"
    $cmd1 += $startTime
}

# Adiciona o vídeo de entrada
$cmd1 += "-i"
$cmd1 += "$inputFile"

# Decide qual parâmetro usar para o tempo final:
if (($startTime -ne "") -and ($endTime -ne "")) {
    # Cenário 1: Trecho (início e fim informados)
    # duração relativa usando -t
    $duration = (New-TimeSpan -Start $startTime -End $endTime).ToString("hh\:mm\:ss")
    $cmd1 += "-t"
    $cmd1 += $duration
}
elseif (($startTime -eq "") -and ($endTime -ne "")) {
    # Cenário 3: Do início original até o ponto absoluto final informado
    $cmd1 += "-to"
    $cmd1 += $endTime
}
# Cenário 2 e 4 já estão implicitamente cobertos (não exigem parâmetro adicional).

$vf_filters = "fps=$taxaQuadros"
if ($resizeVideo.ToUpper() -eq "S") {
    $vf_filters += ",scale='trunc(iw*${resizeVideoPercent}/100/2)*2:trunc(ih*${resizeVideoPercent}/100/2)*2'"
}

$cmd1 += "-vf", $vf_filters
$cmd1 += "-c:v", "libx264"
$cmd1 += "-crf", ($(if ($compressVideo -eq "S") { 35 } else { 28 }))
$cmd1 += "-preset", "ultrafast"
$cmd1 += "-c:a", "aac"
$cmd1 += "-b:a", ($(if ($compressAudio -eq "S") { "32k" } else { "64k" }))
$cmd1 += $videoOut

$cmd2 = @()
if ($startTime -ne "") { $cmd2 += "-ss"; $cmd2 += $startTime }
$cmd2 += "-i"; $cmd2 += $tmpInput
$cmd2 += "-frames:v", "1"
$cmd2 += "-q:v", "2"
$cmd2 += $thumbOut
$cmd2 += "-update", "1"

if ($quiet -eq 1) {
    & ffmpeg @cmd1 *>> "$logFile"
    & ffmpeg @cmd2 *>> "$logFile"
} else {
    ffmpeg @cmd1
    ffmpeg @cmd2
}

Remove-Item $tmpInput -Force

Write-Host "`n✅ Salvo: $videoOut"
Write-Host "📸 Thumb: $thumbOut"
Write-Host "📝 Caption: $captionFile"
if ($quiet -eq 1) {
    Write-Host "🗒️ Log: $logFile"
}

# Criar arquivo de caption com nome do arquivo original
New-Item -ItemType File -Path $captionFile -Force | Out-Null
$inputFileName = Split-Path $inputFile -Leaf
Add-Content -Path $captionFile -Value $inputFileName

if ($reduzirThumbs.ToUpper() -eq "S" -and (Test-Path $thumbOut)) {
    Write-Host "🗜️ Reduzindo tamanho do thumbnail: $(Split-Path $thumbOut -Leaf)" -ForegroundColor DarkGray
    & ffmpeg -i "$thumbOut" -q:v 9 -y "$thumbOut.tmp.jpg" *>$null
    if (Test-Path "$thumbOut.tmp.jpg") {
        Remove-Item "$thumbOut"
        Rename-Item "$thumbOut.tmp.jpg" -NewName (Split-Path $thumbOut -Leaf)
    }
}

if ($resizeThumbs.ToUpper() -eq "S" -and (Test-Path $thumbOut)) {
    Write-Host "📐 Redimensionando thumb: $(Split-Path $thumbOut -Leaf) para ${resizePercent}%" -ForegroundColor DarkGray
    $resizedPath = "$thumbOut.resized.jpg"
    & ffmpeg -i "$thumbOut" -vf "scale=iw*${resizePercent}/100:ih*${resizePercent}/100" -y "$resizedPath" *>$null
    if (Test-Path $resizedPath) {
        Remove-Item "$thumbOut"
        Rename-Item $resizedPath -NewName (Split-Path $thumbOut -Leaf)
    }
}

if ($quiet -eq 1 -and $apagarLogs.ToUpper() -eq "S" -and (Test-Path $logFile)) {
    Write-Host "🧹 Apagando log: $(Split-Path $logFile -Leaf)" -ForegroundColor DarkGray
    Remove-Item "$logFile"
}

# Calcular tamanho total dos arquivos gerados
$tamanhoTotal = 0
$detalhes = @()

if (Test-Path $videoOut) {
    $sizeVideo = (Get-Item $videoOut).Length
    $tamanhoTotal += $sizeVideo
    $detalhes += "  Video: $('{0:N2}' -f ($sizeVideo/1MB)) MB"
}

if (Test-Path $thumbOut) {
    $sizeThumb = (Get-Item $thumbOut).Length
    $tamanhoTotal += $sizeThumb
    $detalhes += "  Thumb: $('{0:N2}' -f ($sizeThumb/1KB)) KB"
}

if (Test-Path $captionFile) {
    $sizeCaption = (Get-Item $captionFile).Length
    $tamanhoTotal += $sizeCaption
    $detalhes += "  Caption: $('{0:N0}' -f $sizeCaption) bytes"
}

Write-Host "`n📊 Tamanho dos arquivos gerados:" -ForegroundColor Yellow
$detalhes | ForEach-Object { Write-Host $_ }
Write-Host "  ────────────────────────────" -ForegroundColor Yellow
if ($tamanhoTotal -ge 1MB) {
    Write-Host "  TOTAL: $('{0:N2}' -f ($tamanhoTotal/1MB)) MB" -ForegroundColor Cyan
} else {
    Write-Host "  TOTAL: $('{0:N2}' -f ($tamanhoTotal/1KB)) KB" -ForegroundColor Cyan
}
