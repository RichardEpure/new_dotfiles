export EDITOR=nvim

# Aliases
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias nvim-def="NVIM_APPNAME=NvimDefault nvim"
alias fd="fdfind"

# Navigates to a file in the current directory and all subdirectories.
function cdf {
	cd $(find . -type d -print | fzf)
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
