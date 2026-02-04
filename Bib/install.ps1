Param(
    [string]$ShortcutName = "Animation Script.lnk"
)

# Diretório do script atual
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Caminhos completos
$VBS_Path = Join-Path $ScriptDir "run.vbs"
$Icon_Path = Join-Path $ScriptDir "icon.ico"
$Desktop = [Environment]::GetFolderPath("Desktop")

Write-Host "SCRIPT_DIR: $ScriptDir"
Write-Host "VBS_PATH: $VBS_Path"
Write-Host "ICON_PATH: $Icon_Path"
Write-Host "DESKTOP_DIR: $Desktop"

# Verifica se run.vbs existe
if (-not (Test-Path $VBS_Path)) {
    Write-Host "Error: run.vbs not found in $ScriptDir"
    exit 1
}

# Verifica se icon.ico existe
if (-not (Test-Path $Icon_Path)) {
    Write-Host "Error: icon.ico not found in $ScriptDir"
    exit 1
}

$ShortcutPath = Join-Path $Desktop $ShortcutName

# Cria o atalho usando WScript.Shell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $VBS_Path
$Shortcut.WorkingDirectory = $ScriptDir 
$Shortcut.IconLocation = $Icon_Path
$Shortcut.WindowStyle = 7
$Shortcut.Save()


# Caminho do diretório acima
$ParentDir = Split-Path $ScriptDir -Parent

# Copia o atalho para o diretório acima do script
Copy-Item -Path $ShortcutPath -Destination $ParentDir -Force


# Verifica se o atalho foi criado com sucesso
if (Test-Path $ShortcutPath) {
    Write-Host "Shortcut created successfully on the Desktop."
} else {
    Write-Host "Error: Failed to create the shortcut."
    exit 1
}
