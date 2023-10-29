#!/bin/bash

# Change to the directory to the root of the repo.
cd "$(dirname "$0")"
cd "../.."

echo "Removing existing files/directories..."
if [ -d ~/.config/nvim ]; then
  echo "Removing ~/.config/nvim"
  rm -rf ~/.config/nvim
fi

if [ -f ~/.gitconfig ]; then
  echo "Removing ~/.gitconfig"
  rm ~/.gitconfig
fi

if [ -f ~/.profile ]; then
  echo "Removing ~/.profile"
  rm ~/.profile
fi

echo "Creating symbolic links..."
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/distributions/ubuntu/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/distributions/ubuntu/.profile ~/.profile

# Install starship
if ! command -v starship &> /dev/null
then
  echo "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh
fi

# Install zoxide
if ! command -v zoxide &> /dev/null
then
  echo "Installing zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
