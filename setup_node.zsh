#!/usr/bin/env zsh

if exists nvm; then
  nvm install node
  nvm use node
  npm install --global yarn
fi
