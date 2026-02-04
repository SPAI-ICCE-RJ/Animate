@echo off
setlocal

REM Diretório do script

pushd "%~dp0.."
set SCRIPT_DIR=%CD%\


REM Caminho do Python portátil
set PYTHON_PORTABLE=%SCRIPT_DIR%python\python.exe

REM Muda para o diretório do script
cd /d "%SCRIPT_DIR%"



REM Verifica se o Python portátil existe
if exist "%PYTHON_PORTABLE%" (
    set PYTHON_EXEC=%PYTHON_PORTABLE%
) else (
    REM Tenta encontrar o Python no PATH do sistema
    where python >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        for /f "delims=" %%p in ('where python') do (
            set PYTHON_EXEC=%%p
            goto :found_python
        )
    ) else (
        echo Python nao encontrado!
        echo Instale o Python ou inclua o Python portatil no diretorio.
        pause
        exit /b 1
    )
)

:found_python
REM Executa o script Python usando o Python encontrado
"%PYTHON_EXEC%" "Bib/Animate_GUI.py"
endlocal

REM Opcional: Pausa após a execução
REM pause
