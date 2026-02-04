<# : chooser.bat


@ECHO OFF

@echo off 
pushd %~dp0
setLocal EnableDELAYedeXpansion
chcp 1254
echo: 

:no

echo:
set /P FRAT=Digite a taxa de quadros padrão se houver animações, se houver somente áudio(s) dê enter:

echo:
echo Escolha o caminho para a pasta com as pastas de quadros.

SET pth=%cd%
SET "pthL=%pth:\=/%"

setlocal 
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
echo:
echo Você escolheu %%~I
set folder=%%I
)
setlocal

endlocal


set "folderL=%folder:\=/%"
chcp 65001
IF exist Anime.tex (DEL /F Anime.tex)
set Anm=Anime.tex
echo \documentclass[12pt, a4paper]{article}>>!Anm!
echo \usepackage{Bib/laudo} >>!Anm!
echo \laudo{Laudo: %LAU%} >>!Anm!
echo \pathframe{%folderL%}>>!Anm!
echo \framerate{%FRAT%}>>!Anm!
echo \begin{document} >>!Anm!
echo \front >>!Anm!
echo \animations >>!Anm!
echo \videos >>!Anm!
echo \audios >>!Anm!
echo \attachments >>!Anm!
echo \end{document} >>!Anm!
chcp 1254

:: Verificar existência do pdflatex
set PORTABLE_PDFLATEX_PATH=miktex\texmfs\install\miktex\bin\x64\pdflatex.exe
if exist "%PORTABLE_PDFLATEX_PATH%" (
    set PDFLATEX_PATH=%~dp0%PORTABLE_PDFLATEX_PATH%
    echo pdflatex encontrado no caminho local: %PDFLATEX_PATH%
) else (
    for %%i in (pdflatex.exe) do set PDFLATEX_PATH=%%~$PATH:i
    if not defined PDFLATEX_PATH (
        echo Erro: pdflatex nao encontrado. Verifique sua instalacao.
        pause
        exit /b 1
    ) else (
        echo pdflatex encontrado no PATH do sistema: %PDFLATEX_PATH%
    )
)



:again
echo:


"%PDFLATEX_PATH%"  -interaction=batchmode -aux-directory=Auxs  --shell-escape Anime.tex
"%PDFLATEX_PATH%"  -interaction=batchmode  -aux-directory=Auxs  --shell-escape Anime.tex


:jmp

echo:
set /p 	LAU=Fez alguma alteração no laudo ou nos quadros? Se deseja anexar a animação ao Laudo digite o número do Laudo e dê enter? [S/N]: 
if %LAU%==S goto :again
if %LAU%==s goto :again
if %LAU%==N goto :senha
if %LAU%==n goto :senha


if not "%outputPath%"=="" goto :cat

if "%LAU%"=="" goto :end 

chcp 65001
IF exist Anime.tex (DEL /F Anime.tex)
set Anm=Anime.tex
echo \documentclass[12pt, a4paper]{article}>>!Anm!
echo \usepackage{Bib/laudo} >>!Anm!
echo \laudo{Laudo: %LAU%} >>!Anm!
echo \pathframe{%folderL%}>>!Anm!
echo \framerate{%FRAT%}>>!Anm!
echo \begin{document} >>!Anm!
echo \front >>!Anm!
echo \animations >>!Anm!
echo \videos >>!Anm!
echo \audios >>!Anm!
echo \attachments >>!Anm!
echo \end{document} >>!Anm!
chcp 1254

echo:
echo Selecione o arquivo PDF onde as animações serão anexadas

if "%~1" == "" goto SELECT
bin\dosomething "%~1"

:SELECT

set tp=1
setlocal
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
echo:
echo Você escolheu %%~I
set filePath=%%~I
)


set outputPath=%filePath:~0,-4%_A.pdf

"Bib/pdftk.exe" "%filePath%" Anime.pdf cat output "%outputPath%"


:again2
echo:


"%PDFLATEX_PATH%"  -interaction=batchmode -aux-directory=Auxs  --shell-escape Anime.tex
"%PDFLATEX_PATH%"  -interaction=batchmode  -aux-directory=Auxs  --shell-escape Anime.tex

"Bib/pdftk.exe" "%filePath%" Anime.pdf cat output "%outputPath%"


:jmp

echo:
set /p 	LN=Fez alguma alteração no laudo ou nos quadros? Deseja repetir a compilação? [S/N]: 
if %LN%==S goto :again2
if %LN%==s goto :again2
if %LN%==N goto :senha
if %LN%==n goto :senha


if not "%outputPath%"=="" goto :cat

if "%LAU%"=="" goto :end 
echo:
echo Selecione o arquivo PDF onde as animações serão anexadas

if "%~1" == "" goto SELECT
bin\dosomething "%~1"

:SELECT

setlocal
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
echo:
echo Você escolheu %%~I
set filePath=%%~I
)


set outputPath=%filePath:~0,-4%_A.pdf

"Bib/pdftk.exe" "%filePath%" Anime.pdf cat output "%outputPath%"

:senha

:: Validar o número do Laudo para nomes de arquivos
set "SAFE_LAU=%LAU:/=_%"
set "SAFE_LAU=%SAFE_LAU:\=_%"

echo:
set /p 	SNH=Deseja atribuir uma senha ao APÊNDICE, se sim digite o a senha se não digite N? [S/N]: 
if %SNH%==N goto :end
if %SNH%==n goto :end


chcp 65001
IF exist Anime.tex (DEL /F Anime.tex)
set Anm=Anime.tex
echo \documentclass[12pt, a4paper]{article}>>!Anm!
echo \usepackage{Bib/laudo} >>!Anm!
echo \laudo{Laudo: %LAU%} >>!Anm!
echo \pathframe{%folderL%}>>!Anm!
echo \framerate{%FRAT%}>>!Anm!
echo \begin{document} >>!Anm!
echo \setcounter{page}{3} >>!Anm!
echo \animations >>!Anm!
echo \videos >>!Anm!
echo \audios >>!Anm!
echo \attachments >>!Anm!
echo \end{document} >>!Anm!
chcp 1254

"%PDFLATEX_PATH%"  -interaction=batchmode -aux-directory=Auxs  --shell-escape Anime.tex
"%PDFLATEX_PATH%"  -interaction=batchmode  -aux-directory=Auxs  --shell-escape Anime.tex


rem "Bib/pdftk.exe" Anime.pdf output Auxs\MULTIMIDIA-Laudo-%LAU%.pdf owner_pw PeritO!@%SNH% user_pw %SNH%
"Bib/pdftk.exe" Anime.pdf output Auxs\MULTIMIDIA-Laudo-%SAFE_LAU%.pdf owner_pw PeritO!@%SNH% user_pw %SNH%


echo:

chcp 65001
IF exist Anime.tex (DEL /F Anime.tex)
set Anm=Anime.tex
echo \documentclass[12pt, a4paper]{article}>>!Anm!
echo \usepackage{Bib/laudo} >>!Anm!
echo \laudo{Laudo: %LAU%} >>!Anm!
echo \begin{document} >>!Anm!
echo \front >>!Anm!
rem echo \begin{figure}\centering\attachfile{Auxs/MULTIMIDIA-Laudo-%LAU%.pdf}\caption{O conte\'{u}do das Multim\'idias foi protegido no arquivo acima por senha indicada na Se\c{c}\~{a}o Material deste Laudo.}\end{figure}>>!Anm!
echo \begin{figure}\centering\attachfile{Auxs/MULTIMIDIA-Laudo-%SAFE_LAU%.pdf}\caption{O conte\'{u}do das Multim\'idias foi protegido no arquivo acima por senha indicada na Se\c{c}\~{a}o Material deste Laudo.}\end{figure}>>!Anm!
echo \end{document} >>!Anm!
chcp 1254

"%PDFLATEX_PATH%"  -interaction=batchmode -aux-directory=Auxs  --shell-escape Anime.tex
"%PDFLATEX_PATH%"  -interaction=batchmode  -aux-directory=Auxs  --shell-escape Anime.tex


rem del Auxs\MULTIMIDIA-Laudo-%LAU%.pdf
del Auxs\MULTIMIDIA-Laudo-%SAFE_LAU%.pdf


"Bib/pdftk.exe" "%filePath%" Anime.pdf cat output "%outputPath%"

:end

#>


Add-Type -AssemblyName System.Windows.Forms
$A=$Env:tp

if ($A -eq 1) {
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "Text Files (*.pdf)|*.pdf|All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }} else {
$f = New-Object System.Windows.Forms.FolderBrowserDialog
$f.rootfolder = "MyComputer"
[void]$f.ShowDialog()
$f.SelectedPath
}



