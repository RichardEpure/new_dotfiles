#Requires -Version 7.0
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
if (-not $IsWindows)
{
    throw 'This installer requires Windows.'
}

$destination = "$env:LOCALAPPDATA/Programs/ControlMyMonitor"
$executable = Join-Path $destination 'ControlMyMonitor.exe'
$pwsh = (Get-Command pwsh.exe -ErrorAction Stop).Source
$script = Join-Path $PSScriptRoot 'Switch-Monitors.ps1'

if (-not (Test-Path -LiteralPath $executable -PathType Leaf))
{
    throw "Download ControlMyMonitor and extract ControlMyMonitor.exe to $destination."
}

$bin = Join-Path $HOME '.local/bin'
New-Item -ItemType Directory -Path $bin -Force | Out-Null
Set-Content -LiteralPath (Join-Path $bin 'Switch-Monitors.ps1') -Value @(
    '$ErrorActionPreference = ''Stop'''
    "& '$($script.Replace("'", "''"))' @args"
)

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
Write-Host 'With the dotfiles profile installed, open a new terminal to use Switch-Monitors 1 or Switch-Monitors 2.'
