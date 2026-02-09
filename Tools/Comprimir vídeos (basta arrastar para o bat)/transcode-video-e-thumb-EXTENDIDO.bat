@echo off
setlocal enabledelayedexpansion

set "SCRIPT=%~dp0transcode-video-e-thumb-EXTENDIDO.ps1"

set /p CASO="Digite o numero do CASO (opcional): "
set /p MOSTRAR="Mostrar saida detalhada do ffmpeg? (S/N): "
set /p APAGAR_LOGS="Apagar arquivos de log? (S/N) [S]: "
if not defined APAGAR_LOGS set APAGAR_LOGS=S
if /I "%MOSTRAR%"=="S" ( set "QUIET=0" ) else ( set "QUIET=1" )

:LOOP_PARAMETROS
set /p TAXA_QUADROS="Taxa de quadros/fps (ex: 3) [3]: "
if not defined TAXA_QUADROS set TAXA_QUADROS=3

set /p REDUZIR_THUMBS="Reduzir tamanho dos thumbs? (S/N) [N]: "
if not defined REDUZIR_THUMBS set REDUZIR_THUMBS=N



set /p REDIMENSIONAR_THUMBS="Redimensionar thumbs? (S/N) [N]: "
if /I "%REDIMENSIONAR_THUMBS%"=="S" (
    set /p PERCENTUAL_RESIZE="Percentual de redimensionamento (ex: 60): "
) else (
	set REDIMENSIONAR_THUMBS=N
    set PERCENTUAL_RESIZE=100
)

set /p COMPRESS_VIDEO="Compressao de video maxima? (S/N) [N]: "
if not defined COMPRESS_VIDEO set COMPRESS_VIDEO=N

set /p COMPRESS_AUDIO="Compressao de audio maxima? (S/N) [N]: "
if not defined COMPRESS_AUDIO set COMPRESS_AUDIO=N

set /p REDIMENSIONAR_VIDEO="Reduzir resolucao do video? (S/N) [N]: "
if /I "%REDIMENSIONAR_VIDEO%"=="S" (
    set /p PERCENTUAL_VIDEO="Percentual de reducao da resolucao (ex: 50): "
) else (
	set REDIMENSIONAR_VIDEO=N
    set PERCENTUAL_VIDEO=100
)

:LOOP_PROCESSAR
set COUNT=1
for %%F in (%*) do (
    echo --------------------------
    echo #!COUNT! - Arquivo: %%~nxF
    set /p INICIO="Tempo INICIO (HH:MM:SS ou deixe em branco p/ inicio): "
    set /p FINAL="Tempo FINAL  (HH:MM:SS ou deixe em branco p/ fim/video completo): "
    powershell -ExecutionPolicy Bypass -File "!SCRIPT!" -inputFile "%%~F" -startTime "!INICIO!" -endTime "!FINAL!" -caso "!CASO!" -indice !COUNT! -quiet !QUIET! -reduzirThumbs !REDUZIR_THUMBS! -apagarLogs !APAGAR_LOGS! -resizeThumbs !REDIMENSIONAR_THUMBS! -resizePercent !PERCENTUAL_RESIZE! -compressVideo !COMPRESS_VIDEO! -compressAudio !COMPRESS_AUDIO! -resizeVideo !REDIMENSIONAR_VIDEO! -resizeVideoPercent !PERCENTUAL_VIDEO! -taxaQuadros !TAXA_QUADROS!
    set /a COUNT+=1
)

REM Calcular tamanho total dos arquivos gerados
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where name^="C:" get freespace /value') do set DUMMY=%%a

if defined CASO (
    set "OUTDIR=D:\Casos\!CASO!\Multi\Videos"
) else (
    set "OUTDIR=!USERPROFILE!\Downloads"
)

echo.
echo ==================================================
echo 📊 RESUMO GERAL - Tamanho dos arquivos gerados:
echo ==================================================

setlocal enabledelayedexpansion
set TAMANHO_TOTAL=0

for /l %%i in (1,1,!COUNT!) do (
    if exist "!OUTDIR!\Video%%i.mp4" (
        for %%Z in ("!OUTDIR!\Video%%i.mp4") do (
            echo   Video%%i.mp4: %%~zZ bytes
            set /a TAMANHO_TOTAL+=%%~zZ
        )
    )
    if exist "!OUTDIR!\VideoThumb%%i.jpg" (
        for %%Z in ("!OUTDIR!\VideoThumb%%i.jpg") do (
            echo   VideoThumb%%i.jpg: %%~zZ bytes
            set /a TAMANHO_TOTAL+=%%~zZ
        )
    )
)

echo ==================================================
echo TOTAL: !TAMANHO_TOTAL! bytes

echo.
echo ==========================
echo Opcoes:
echo P = Refazer a partir da definicao de PARAMETROS
echo T = Refazer so a determinacao dos TEMPOS
echo S = SAIR
echo ==========================
set /p OPCAO="Escolha uma opcao (P/T/S): "
if /I "%OPCAO%"=="P" goto LOOP_PARAMETROS
if /I "%OPCAO%"=="T" goto LOOP_PROCESSAR
if /I "%OPCAO%"=="S" goto FIM
goto FIM

:FIM
pause

