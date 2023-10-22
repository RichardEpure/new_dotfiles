$logPath = "$env:USERPROFILE/Profile.log"
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
"`n$($stopwatch.ElapsedMilliseconds)ms`tProfile load started" | Out-File -FilePath $logPath -Append

# Aliases
Set-Alias -Name sa -Value Start-AdminSession
Set-Alias -Name cdf -Value Set-DirectoryFuzzy

"$($stopwatch.ElapsedMilliseconds)ms`tAliases set" | Out-File -FilePath $logPath -Append

# Functions
function Set-DirectoryFuzzy {
    <#
    .SYNOPSIS
        Navigates to a file in the current directory and all subdirectories.
    #>
    param (
        # The drive to navigate to before searching.
        [string]$DriveLetter
    )

    if ($DriveLetter) {
        Set-Location $DriveLetter":/"
    } 

    Get-ChildItem . -Recurse | Where-Object { $_.PSIsContainer } | Invoke-Fzf | Set-Location
}

function Start-AdminSession {
    <#
    .SYNOPSIS
        Starts a new PowerShell session with elevated rights.
    #>
    Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command &{Set-Location $PWD}"
}

"$($stopwatch.ElapsedMilliseconds)ms`tFunctions loaded" | Out-File -FilePath $logPath -Append

# Promp Setup
Invoke-Expression (&starship init powershell)

$stopwatch.Stop()
"$($stopwatch.ElapsedMilliseconds)ms`tProfile load complete" | Out-File -FilePath $logPath -Append
