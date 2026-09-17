_mux_pick() {
	local kind="$1" format items selection query='' key row target label session answer
	command -v tmux >/dev/null && command -v fzf >/dev/null || {
		printf 'Install tmux and fzf first.\n' >&2
		return 1
	}
	local -a list_args
	if [ "$kind" = session ]; then
		format=$'#{session_id}\t#{session_name} (#{session_windows} windows)'
		list_args=(list-sessions -F "$format")
	else
		format=$'#{session_id}:#{window_id}\t#{session_name}:#{window_index} #{window_name} [#{pane_current_command}]'
		list_args=(list-windows -a -F "$format")
	fi
	while :; do
		if ! items=$(tmux "${list_args[@]}" 2>&1); then
			case "$items" in
				*'no server running'*|*'no sessions'*|*'No such file or directory'*)
					printf 'No sessions found.\n'
					return 0
					;;
			esac
			printf '%s\n' "$items" >&2
			return 1
		fi
		[ -n "$items" ] || { printf 'No %ss found.\n' "$kind"; return; }
		selection=$(printf '%s\n' "$items" | fzf --delimiter=$'\t' --with-nth=2.. --no-multi \
			--print-query --expect=ctrl-x --query="$query" --prompt="${kind}s> " \
			--header='Enter: attach | Ctrl-x: kill selected | Esc: cancel') || return 0
		query=${selection%%$'\n'*}
		selection=${selection#*$'\n'}
		key=${selection%%$'\n'*}
		row=${selection#*$'\n'}
		target=${row%%$'\t'*}
		label=${row#*$'\t'}
		# Validate machine IDs; labels never become shell commands.
		if ! [[ "$target" =~ ^\$[0-9]+(:@[0-9]+)?$ ]]; then
			printf 'Invalid mux target.\n' >&2
			return 1
		fi
		if [ "$key" = ctrl-x ]; then
			printf "Kill %s '%s' and all its processes? [y/N] " "$kind" "$label" > /dev/tty
			IFS= read -r answer < /dev/tty || return
			case "$answer" in y|Y) tmux "kill-$kind" -t "$target" ;; esac
			continue
		fi
		session=${target%%:*}
		if [ "$kind" = window ]; then
			tmux select-window -t "$target" || continue
		fi
		if [ -n "${TMUX:-}" ]; then
			tmux switch-client -t "$target"
		else
			tmux attach-session -t "$session"
		fi
		return
	done
}

mux-sessions() { _mux_pick session; }
mux-windows() { _mux_pick window; }
alias ms=mux-sessions
alias mw=mux-windows
