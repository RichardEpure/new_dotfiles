$logPath = "$env:USERPROFILE/Profile.log"
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
"`n$($stopwatch.ElapsedMilliseconds)ms`tProfile load started" | Out-File -FilePath $logPath -Append

# Aliases
Set-Alias -Name sa -Value Start-AdminSession
Set-Alias -Name cdf -Value Set-DirectoryFuzzy
Set-Alias -Name ya -Value Open-Yazi

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

function Open-Yazi {
    <#
    .SYNOPSIS
        Opens yazi at your current directory. cd into the last directory in yazi when you exit.
    #>
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -Path $cwd
    }
    Remove-Item -Path $tmp
}

"$($stopwatch.ElapsedMilliseconds)ms`tFunctions loaded" | Out-File -FilePath $logPath -Append

# Promp Setup
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

$stopwatch.Stop()
"$($stopwatch.ElapsedMilliseconds)ms`tProfile load complete" | Out-File -FilePath $logPath -Append
