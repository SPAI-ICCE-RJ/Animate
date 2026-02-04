<# : chooser.bat

@ECHO OFF

@echo off 
pushd %~dp0
setLocal EnableDELAYedeXpansion
::chcp 1254
echo: 
echo:

:: set your your ffmpeg bin folder path here

set folder=""Y:\Ferramentas\Audio-Imagem\Outros_utilizados-via-rede\Reprodutores\ffmpeg-20161204-1f5630a-win64-static\bin""


if not "folder"=="" goto jmp


set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please choose a folder.',0,0).self.path""

for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "folder=%%I"
setlocal enabledelayedexpansion
echo:
echo Você escolheu o caminho !folder!
endlocal


if /I "%folder:~0,3%"=="%folder%" (set folder=%folder:~0,2%) 

:jmp


SET pth=%cd%


CD /D %folder% || GOTO:error
PROMPT $P$_$G
SET PATH=%CD%;%PATH%
CLS
ffmpeg -version
ECHO
ECHO For help run: ffmpeg -h
ECHO For formats run: ffmpeg -formats ^| more
ECHO For codecs run: ffmpeg -codecs ^| more
ECHO
ECHO Current directory is now: "%CD%"
ECHO The bin directory has been added to PATH
ECHO



echo:
echo Select the video to export frames

if "%~1" == "" goto SELECT
bin\dosomething "%~1"

:SELECT

setlocal
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
echo: 
echo You chose %%I
set "folder=%%~I"
)

rmdir /s  "%pth%\Seq

mkdir "%pth%\Seq

SET "AGN=0"

:again

echo:
set /p SMPL=Level of change between samples [0-1]:
echo:
set /p TMN=How many seconds between samples:




rem -qscale:v 15

ffmpeg -hide_banner -loglevel error -i "%folder%" -vf "select=gt(scene\,%SMPL%)*('isnan(prev_selected_t)+gte(t-prev_selected_t\,%TMN%)')" -vsync vfr -qscale:v 2 -start_number %AGN% -y "%pth%\Seq\frame%%d.jpg"


echo:

set /p AGN=Do it again starting from the frame number?: 

if not %AGN%=="" goto :again


#>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $false
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }