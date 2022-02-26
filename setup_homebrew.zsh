#!/usr/bin/env zsh

if exists brew; then
  echo 'Skipping Brew install'
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle --verbose


