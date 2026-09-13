#Requires -Version 7.0
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
$destination = "$env:LOCALAPPDATA/Programs/ControlMyMonitor"
$executable = Join-Path $destination 'ControlMyMonitor.exe'
$pwsh = (Get-Command pwsh.exe -ErrorAction Stop).Source
$script = Join-Path $PSScriptRoot 'Switch-Monitors.ps1'

if (-not (Test-Path -LiteralPath $executable -PathType Leaf))
{
    throw "Download ControlMyMonitor and extract ControlMyMonitor.exe to $destination."
}

$shell = New-Object -ComObject WScript.Shell
foreach ($pc in 1, 2)
{
    $shortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) "Switch to PC $pc.lnk"))
    $shortcut.TargetPath = $pwsh
    $shortcut.Arguments = "-NoLogo -NoProfile -File `"$script`" $pc"
    $shortcut.WorkingDirectory = $PSScriptRoot
    $shortcut.IconLocation = "$executable,0"
    $shortcut.Description = "Switch all monitor inputs to PC $pc"
    $shortcut.Save()
}
Write-Host "ControlMyMonitor: $executable"
Write-Host 'Start Menu shortcuts created. Search for "Switch to PC" in Start or PowerToys Run.'
