function Select-MuxItem
{
    param([ValidateSet('session', 'window')][string]$Kind)

    foreach ($tool in 'psmux', 'fzf')
    {
        if (-not (Get-Command $tool -CommandType Application -ErrorAction SilentlyContinue))
        {
            Write-Error "Install $tool and restart your terminal so it is on PATH."
            return
        }
    }

    $PSNativeCommandUseErrorActionPreference = $false
    $format = '#{session_id}' + "`t" + '#{session_name} (#{session_windows} windows)'
    $listArgs = @('list-sessions', '-F', $format)
    if ($Kind -eq 'window')
    {
        $format = '#{session_id}:#{window_id}' + "`t" + '#{session_name}:#{window_index} #{window_name} [#{pane_current_command}]'
        $listArgs = @('list-windows', '-a', '-F', $format)
    }

    $query = ''
    while ($true)
    {
        $items = @(& psmux @listArgs 2>&1)
        if ($LASTEXITCODE -ne 0)
        {
            $message = ($items | Out-String).Trim()
            if ($message -match 'no server running|no sessions') { Write-Host 'No sessions found.' }
            else { Write-Error $message }
            return
        }
        if ($items.Count -eq 0) { Write-Host "No ${Kind}s found."; return }

        # --expect returns to this loop: no shell interpolation of names or fzf placeholders.
        $selection = @($items | fzf --delimiter "`t" --with-nth '2..' --no-multi --print-query --expect ctrl-x --query $query --prompt "${Kind}s> " --header 'Enter: attach | Ctrl-x: kill selected | Esc: cancel')
        if ($LASTEXITCODE -ne 0 -or $selection.Count -lt 3) { return }
        $query, $key, $row = $selection
        $target, $label = $row -split "`t", 2
        if ($target -notmatch '^\$\d+(:@\d+)?$') { Write-Error 'Invalid mux target.'; return }

        if ($key -eq 'ctrl-x')
        {
            if ((Read-Host "Kill $Kind '$label' and all its processes? [y/N]") -ieq 'y')
            {
                & psmux "kill-$Kind" -t $target
            }
            continue
        }

        $session = ($target -split ':', 2)[0]
        if ($Kind -eq 'window')
        {
            & psmux select-window -t $target
            if ($LASTEXITCODE -ne 0) { continue }
        }
        if ($env:TMUX -or $env:PSMUX_SESSION)
        {
            & psmux switch-client -t $target
        }
        else
        {
            & psmux attach-session -t $session
        }
        return
    }
}

function mux-sessions { Select-MuxItem session }
function mux-windows { Select-MuxItem window }
Set-Alias -Name ms -Value mux-sessions
Set-Alias -Name mw -Value mux-windows
