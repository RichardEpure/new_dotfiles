# Sourced by .zshrc; keep non-interactive shells free of prompt/completion setup.
[[ -o interactive ]] || return

typeset -U path
if ! (( $+commands[brew] )); then
	for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
		if [[ -x "$brew_bin" ]]; then
			path=("${brew_bin:h}" $path)
			break
		fi
	done
	unset brew_bin
fi
if (( $+commands[brew] )); then
	eval "$(brew shellenv)"
fi
path=("$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.opencode/bin" $path)
export EDITOR=nvim

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS
unsetopt BEEP
autoload -Uz compinit
compinit

# %N is this sourced file; :A resolves symlinks and :h takes its directory.
source "${${(%):-%N}:A:h}/../../mux/mux.sh"

cdf() {
	local dir
	dir=$(fd --type d --hidden --follow . "${1:-.}" | fzf) || return
	[[ -n "$dir" ]] && builtin cd -- "$dir"
}

if (( $+commands[starship] )); then
	eval "$(starship init zsh)"
fi
if (( $+commands[zoxide] )); then
	eval "$(zoxide init zsh)"
fi
