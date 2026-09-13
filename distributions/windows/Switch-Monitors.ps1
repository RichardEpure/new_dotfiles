#Requires -Version 7.0
<#
.SYNOPSIS
    Sends all configured monitors to PC 1 or PC 2 using DDC/CI.
.EXAMPLE
    ./Switch-Monitors.ps1 2 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('1', '2')]
    [string]$PC,
    [string]$ConfigPath = "$PSScriptRoot/../monitor-inputs.json",
    [string]$ToolPath = "$env:LOCALAPPDATA/Programs/ControlMyMonitor/ControlMyMonitor.exe"
)

$ErrorActionPreference = 'Stop'
$monitors = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -NoEnumerate
if ($monitors -isnot [array] -or $monitors.Count -eq 0)
{
    throw 'The monitor configuration must be a nonempty JSON array.'
}

# Validate every entry before sending any writes.
$toolArguments = @()
foreach ($monitor in $monitors)
{
    $inputValue = $monitor."pc$PC"
    if ([string]::IsNullOrWhiteSpace($monitor.name) -or
        [string]::IsNullOrWhiteSpace($monitor.shortMonitorId) -or
        ($inputValue -isnot [long] -and $inputValue -isnot [int]) -or
        $inputValue -lt 0 -or $inputValue -gt 65535)
    {
        throw "Invalid name, shortMonitorId, or PC $PC input in $ConfigPath."
    }
    $toolArguments += '/SetValue', [string]$monitor.shortMonitorId, '60', [string]$inputValue
}
if (@($monitors.shortMonitorId | Sort-Object -Unique).Count -ne $monitors.Count)
{
    throw 'Each monitor must have a unique shortMonitorId.'
}

if ($PSCmdlet.ShouldProcess(($toolArguments -join ' '), "Send monitor inputs to PC $PC"))
{
    if (-not (Test-Path -LiteralPath $ToolPath -PathType Leaf))
    {
        throw "ControlMyMonitor not found at $ToolPath. Download and extract it there, or pass -ToolPath."
    }
    # Piping waits for this GUI executable to finish; use one invocation for all displays.
    & $ToolPath @toolArguments | Out-Host
    if ($LASTEXITCODE -ne 0)
    {
        throw "ControlMyMonitor exited with code $LASTEXITCODE. Check the inputs manually."
    }
    Write-Host "Input commands sent for PC $PC. Confirm the displays switched."
}
