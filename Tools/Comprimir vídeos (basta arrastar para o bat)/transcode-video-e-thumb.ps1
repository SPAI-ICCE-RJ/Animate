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
    [int]$resizePercent = 100
)

# Define pasta de saída
if ($caso) {
    $outDir = "C:\Casos\$caso"
} else {
    $outDir = "$env:USERPROFILE\Downloads"
}
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Nomes base
$base     = "Video$indice"
$videoOut = Join-Path $outDir "$base.mp4"
$thumbOut = Join-Path $outDir "VideoThumb${indice}.jpg"
$logFile  = Join-Path $outDir "$base.log"

# Verifica ffmpeg
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ffmpeg não encontrado no PATH." -ForegroundColor Red
    exit 1
}

# Mensagem visual
Write-Host "`n🎞️ Processando vídeo #${indice} - $inputFile" -ForegroundColor Cyan

# Monta argumentos
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

# Restante dos parâmetros
$cmd1 += @(
#    "-vf", "fps=15,scale=640:-1",
    "-vf", "fps=15,scale=640:-2",
    "-c:v", "libx264",
    "-crf", "28",
    "-preset", "fast",
    "-c:a", "aac",
    "-b:a", "64k",
    "$videoOut"
)

$cmd2 = @()

# Prioriza -ss antes de -i (obrigatório para HEVC raw como .dar)
if ($startTime -ne "") {
    $cmd2 += "-ss"
    $cmd2 += $startTime
}

$cmd2 += "-i"
$cmd2 += "$inputFile"

$cmd2 += @(
    "-frames:v", "1",
    "-q:v", "2",
    "$thumbOut",
    "-update", "1"
)

# Execução
if ($quiet -eq 1) {
    & ffmpeg @cmd1 *>> "$logFile"
    & ffmpeg @cmd2 *>> "$logFile"
} else {
    ffmpeg @cmd1
    ffmpeg @cmd2
}

# Feedback final
Write-Host "`n✅ Salvo: $videoOut"
Write-Host "📸 Thumb: $thumbOut"
if ($quiet -eq 1) {
    Write-Host "🗒️ Log: $logFile"
}

# Pós-processamento opcional: reduzir tamanho dos thumbs
if ($reduzirThumbs.ToUpper() -eq "S" -and (Test-Path $thumbOut)) {
    Write-Host "🗜️ Reduzindo tamanho do thumbnail: $(Split-Path $thumbOut -Leaf)" -ForegroundColor DarkGray
    & ffmpeg -i "$thumbOut" -q:v 9 -y "$thumbOut.tmp.jpg" *>$null
    if (Test-Path "$thumbOut.tmp.jpg") {
        Remove-Item "$thumbOut"
        Rename-Item "$thumbOut.tmp.jpg" -NewName (Split-Path $thumbOut -Leaf)
    }
}

# Pós-processamento opcional: redimensionamento de thumbs
if ($resizeThumbs.ToUpper() -eq "S" -and (Test-Path $thumbOut)) {
    Write-Host "📐 Redimensionando thumb: $(Split-Path $thumbOut -Leaf) para ${resizePercent}%" -ForegroundColor DarkGray
    $resizedPath = "$thumbOut.resized.jpg"
#    & ffmpeg -i "$thumbOut" -vf "scale=iw*${resizePercent}/100:ih*${resizePercent}/100" -y "$resizedPath" *>$null
    & ffmpeg -i "$thumbOut" -vf "scale=trunc(iw*$percentualResolucao/2)*2:trunc(ih*$percentualResolucao/2)*2" -y "$resizedPath" *>$null
    if (Test-Path "$resizedPath") {
        Remove-Item "$thumbOut"
        Rename-Item "$resizedPath" -NewName (Split-Path $thumbOut -Leaf)
    }
}

# Exclusão de log, se solicitado
if ($quiet -eq 1 -and $apagarLogs.ToUpper() -eq "S" -and (Test-Path $logFile)) {
    Write-Host "🧹 Apagando log: $(Split-Path $logFile -Leaf)" -ForegroundColor DarkGray
    Remove-Item "$logFile"
}

