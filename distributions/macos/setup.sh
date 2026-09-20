#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"

if [ "$(uname -s)" != Darwin ]; then
	printf 'This installer requires macOS.\n' >&2
	exit 1
fi

# Homebrew may be installed without being on this shell's PATH yet.
if ! command -v brew >/dev/null 2>&1; then
	for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
		if [ -x "$brew_bin" ]; then
			export PATH="$(dirname -- "$brew_bin"):$PATH"
			break
		fi
	done
fi
if ! command -v brew >/dev/null 2>&1; then
	printf 'Install Homebrew from https://brew.sh, then rerun this setup.\n' >&2
	exit 1
fi
brew_environment="$(brew shellenv)"
eval "$brew_environment"

brew install git gh neovim tmux fzf starship zoxide fd ripgrep jq lazygit tree-sitter-cli

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
	mkdir -p -- "$NVM_DIR"
	curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | PROFILE=/dev/null NODE_VERSION= bash
fi
(
	# nvm expects a non-strict shell; keep that change local and propagate failures.
	set +eu
	. "$NVM_DIR/nvm.sh" --no-use || exit $?
	if ! nvm version node >/dev/null 2>&1; then
		nvm install --lts || exit $?
	fi
)

link_config() {
	local source="$1" destination="$2"
	[ -e "$source" ] || { printf 'Missing config: %s\n' "$source" >&2; return 1; }
	if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then return; fi
	mkdir -p -- "$(dirname -- "$destination")"
	# Replace conflicts without backups; no trailing slash, so symlink targets survive.
	rm -rf -- "$destination"
	ln -s -- "$source" "$destination"
}

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
link_config "$root/mux/conf" "$HOME/.tmux"
link_config "$root/mux/conf/tmux.conf" "$HOME/.tmux.conf"
link_config "$root/nvim" "$config_home/nvim"
link_config "$root/.globalignore" "$HOME/.gitignore"
link_config "$root/distributions/macos/.gitconfig" "$HOME/.gitconfig"

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
if { [ -e "$zshrc" ] || [ -L "$zshrc" ]; } && [ ! -f "$zshrc" ]; then
	printf '%s is not a regular file or a valid link to one.\n' "$zshrc" >&2
	exit 1
fi
mkdir -p -- "$(dirname -- "$zshrc")"
printf -v source_line 'source %q' "$root/distributions/macos/profile.zsh"
if [ ! -f "$zshrc" ] || ! grep -Fqx -- "$source_line" "$zshrc"; then
	printf '\n%s\n' "$source_line" >> "$zshrc"
fi

printf 'macOS dotfiles configured. Open a new terminal to load the Zsh profile.\n'
