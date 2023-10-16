$logPath = "$env:USERPROFILE/Profile.log"
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
"`n$($stopwatch.ElapsedMilliseconds)ms`tProfile load started" | Out-File -FilePath $logPath -Append

# Promp Setup
Invoke-Expression (&starship init powershell)

$stopwatch.Stop()
"$($stopwatch.ElapsedMilliseconds)ms`tProfile load complete" | Out-File -FilePath $logPath -Append
