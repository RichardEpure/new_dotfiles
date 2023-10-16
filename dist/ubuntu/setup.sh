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

echo "Creating symbolic links..."
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
