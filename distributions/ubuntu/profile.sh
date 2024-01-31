export EDITOR=nvim

# Aliases
alias minvim="NVIM_APPNAME=nvim_minimal nvim"
alias fd="fdfind"

# Navigates to a file in the current directory and all subdirectories.
function cdf {
	# define variable dir to store the directory
	dir=$(fd -td -tl -u | fzf)
	if [ -n "$dir" ]; then
		cd "$dir"
	fi
}

# Opens yazi at your current directory. cd into the last directory in yazi when you exit.
function ya {
	tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Prompt setup
eval "$(starship init bash)"
eval "$(zoxide init bash)"

# Get rid of notification bell
bind 'set bell-style none'
