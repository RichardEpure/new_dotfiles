#!/usr/bin/env bash

set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
mode="${1:-}"

select_mode() {
	case "$mode" in
		--all) printf 'all\n' ;;
		--opencode) printf 'opencode\n' ;;
		--dotfiles) printf 'dotfiles\n' ;;
		"")
			printf 'Select what to install:\n1. All\n2. Only OpenCode\n3. Dotfiles only\n' >&2
			while true; do
				read -r -p "Choice: " choice
				case "$choice" in
					1) printf 'all\n'; return ;;
					2) printf 'opencode\n'; return ;;
					3) printf 'dotfiles\n'; return ;;
					*) printf 'Enter 1, 2, or 3.\n' >&2 ;;
				esac
			done
			;;
		*)
			printf 'Usage: %s [--all|--opencode|--dotfiles]\n' "$0" >&2
			exit 2
			;;
	esac
}

install_opencode() {
	local private_root
	private_root="$(dirname -- "$root")/opencode-config"

	if [ -e "$private_root" ] \
		&& [ "$(git -C "$private_root" rev-parse --show-toplevel 2>/dev/null || true)" = "$(realpath -- "$private_root")" ]; then
		git -C "$private_root" pull --ff-only || {
			printf 'Failed to update %s. Commit or stash local changes and retry.\n' "$private_root" >&2
			exit 1
		}
	elif [ -e "$private_root" ]; then
		printf '%s exists but is not a Git repository.\n' "$private_root" >&2
		exit 1
	elif command -v gh >/dev/null 2>&1; then
		gh repo clone RichardEpure/opencode-config "$private_root" || {
			printf 'Failed to clone the private OpenCode repository. Check GitHub authentication.\n' >&2
			exit 1
		}
	else
		git clone git@github.com:RichardEpure/opencode-config.git "$private_root" || {
			printf 'Failed to clone the private OpenCode repository. Check SSH authentication.\n' >&2
			exit 1
		}
	fi

	"$private_root/setup.sh"
}

selected_mode="$(select_mode)"
if [ "$selected_mode" = "all" ] || [ "$selected_mode" = "opencode" ]; then
	install_opencode
fi
if [ "$selected_mode" = "opencode" ]; then
	exit 0
fi

echo "Removing existing files/directories..."
if [ -d ~/.config/nvim ]; then
	echo "Removing ~/.config/nvim"
	rm -rf ~/.config/nvim
fi

if [ -d ~/.config/yazi ]; then
	echo "Removing ~/.config/yazi"
	rm -rf ~/.config/yazi
fi

if [ -f ~/.gitconfig ]; then
	echo "Removing ~/.gitconfig"
	rm ~/.gitconfig
fi

if [ -f ~/.gitignore ]; then
	echo "Removing ~/.gitignore"
	rm ~/.gitignore
fi

if [ -f ~/.bashrc ]; then
	echo "Removing ~/.bashrc"
	rm ~/.bashrc
fi

echo "Creating symbolic links..."
mkdir -p ~/.config
ln -sfn "$root/nvim" ~/.config/nvim
ln -sfn "$root/nvim_minimal" ~/.config/nvim_minimal
ln -sfn "$root/yazi" ~/.config/yazi
ln -sfn "$root/distributions/ubuntu/.gitconfig" ~/.gitconfig
ln -sfn "$root/.globalignore" ~/.gitignore
ln -sfn "$root/distributions/ubuntu/.bashrc" ~/.bashrc

# Install starship
if ! command -v starship &>/dev/null; then
	echo "Installing starship..."
	curl -sS https://starship.rs/install.sh | sh
fi

# Install zoxide
if ! command -v zoxide &>/dev/null; then
	echo "Installing zoxide..."
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
