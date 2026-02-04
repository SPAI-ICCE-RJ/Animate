@echo off
setlocal enabledelayedexpansion

REM Define o script PowerShell
set "SCRIPT=%~dp0transcode-video-e-thumb.ps1"

REM Pergunta o número do CASO (opcional)
set /p CASO="Digite o numero do CASO (opcional): "

REM Pergunta se deseja saída detalhada
set /p MOSTRAR="Mostrar saida detalhada do ffmpeg? (S/N): "
if /I "%MOSTRAR%"=="S" (
    set "QUIET=0"
) else (
    set "QUIET=1"
)

REM Opções de pós-processamento

set REDUZIR_THUMBS=N
set APAGAR_LOGS=S
set REDIMENSIONAR_THUMBS=N
set PERCENTUAL_RESIZE=60

set /p REDUZIR_THUMBS="Reduzir tamanho dos thumbs? (S/N) [N]: "
set /p APAGAR_LOGS="Apagar arquivos de log? (S/N) [S]: "

set /p REDIMENSIONAR_THUMBS="Redimensionar thumbs? (S/N) [N]: "
if /I "%REDIMENSIONAR_THUMBS%"=="S" (
    set /p PERCENTUAL_RESIZE="Percentual de redimensionamento [60]: "
) else (
    set PERCENTUAL_RESIZE=100
)

REM Inicializa contador
set COUNT=1

REM Itera sobre todos os arquivos arrastados
for %%F in (%*) do (
    echo --------------------------
    echo #!COUNT! - Arquivo: %%~nxF

    set /p INICIO="Tempo INICIO (HH:MM:SS ou deixe em branco p/ inicio): "
    set /p FINAL="Tempo FINAL  (HH:MM:SS ou deixe em branco p/ fim/video completo): "

    REM powershell -ExecutionPolicy Bypass -File "%~dp0transcode-video-e-thumb.ps1" -inputFile "%%F" -startTime "!INICIO!" -endTime "!FINAL!" -caso "!CASO!" -indice !COUNT! -quiet !QUIET! -reduzirThumbs !REDUZIR_THUMBS! -apagarLogs !APAGAR_LOGS! -resizeThumbs !REDIMENSIONAR_THUMBS! -resizePercent !PERCENTUAL_RESIZE!
	powershell -ExecutionPolicy Bypass -Command "& { & '%~dp0transcode-video-e-thumb.ps1' -inputFile '%%~fF' -startTime '!INICIO!' -endTime '!FINAL!' -caso '!CASO!' -indice !COUNT! -quiet !QUIET! -reduzirThumbs '!REDUZIR_THUMBS!' -apagarLogs '!APAGAR_LOGS!' -resizeThumbs '!REDIMENSIONAR_THUMBS!' -resizePercent !PERCENTUAL_RESIZE! }"


    set /a COUNT+=1
)

pause
