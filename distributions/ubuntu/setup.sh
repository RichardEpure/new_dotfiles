#!/usr/bin/env bash

set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

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
rm -rf -- "$HOME/.tmux"
ln -s -- "$root/mux/conf" "$HOME/.tmux"
ln -sfn "$root/mux/conf/tmux.conf" ~/.tmux.conf
mkdir -p ~/.config
ln -sfn "$root/nvim" ~/.config/nvim
ln -sfn "$root/nvim_minimal" ~/.config/nvim_minimal
ln -sfn "$root/yazi" ~/.config/yazi
ln -sfn "$root/distributions/ubuntu/.gitconfig" ~/.gitconfig
ln -sfn "$root/.globalignore" ~/.gitignore
ln -sfn "$root/distributions/ubuntu/.bashrc" ~/.bashrc

if ! command -v tmux >/dev/null || ! command -v fzf >/dev/null; then
	sudo apt-get update
	sudo apt-get install -y tmux fzf
fi

# Install tree-sitter CLI
tree_sitter_min_version="0.26.1"
if ! command -v tree-sitter >/dev/null 2>&1 \
	|| ! dpkg --compare-versions "$(tree-sitter --version | awk '{print $2}')" ge "$tree_sitter_min_version"; then
	if ! command -v cargo >/dev/null 2>&1; then
		printf 'cargo is required to install tree-sitter-cli %s or newer.\n' "$tree_sitter_min_version" >&2
		exit 1
	fi

	echo "Installing tree-sitter CLI..."
	cargo install --locked tree-sitter-cli
fi

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
