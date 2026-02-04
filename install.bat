@echo off
setlocal

REM Criar pasta Auxs se não existir
if not exist "%~dp0Auxs" (
    mkdir "%~dp0Auxs"
    echo Pasta Auxs criada com sucesso.
)

REM Caminho do script PowerShell
set "PS_SCRIPT=%~dp0Bib\install.ps1"

REM Executa o script PowerShell com execução temporariamente liberada
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

endlocal
