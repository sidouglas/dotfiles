#!/usr/bin/env zsh
export NONINTERACTIVE=1
echo "\n<<< Starting Homebrew Setup >>>\n"

if exists brew; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# A fresh install isn't on PATH yet; `zsh_custom` runs shellenv but is only
# sourced by interactive shells, so do it here for the rest of this script.
if ! exists brew && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! exists brew; then
  echo "brew is still not on PATH; its install did not complete."
  echo "Homebrew needs sudo, so run this script directly in a terminal:"
  echo "  cd ~/.dotfiles && ./setup_homebrew.zsh"
  exit 1
fi

# TODO: Keep an eye out for a different `--no-quarantine` solution.
# Currently, you can't do `brew bundle --no-quarantine` as an option.
# export HOMEBREW_CASK_OPTS="--no-quarantine --no-binaries"
# https://github.com/Homebrew/homebrew-bundle/issues/474

# HOMEBREW_CASK_OPTS is exported in `zshenv` with
# `--no-quarantine` and `--no-binaries` options,
# which makes them available to Homebrew for the
# first install (before our `zshrc` is sourced).

DOTFILES="${0:a:h}"
HOMEBREW_DIR="$DOTFILES/$(hostname)"
: ${HOMEBREW_BUNDLE_FILE:="$HOMEBREW_DIR/Brewfile"}

if [[ ! -f "$HOMEBREW_BUNDLE_FILE" ]]; then
  found=($DOTFILES/*/Brewfile(N))
  hosts=(${found:h:t})

  if (( ${#hosts} == 0 )); then
    echo "No Brewfile anywhere in $DOTFILES to start from."
    exit 1
  fi

  if [[ ! -t 0 ]]; then
    echo "No Brewfile for $(hostname), and no terminal to ask on."
    echo "Run ./setup_homebrew.zsh directly, or set HOMEBREW_BUNDLE_FILE to one of:"
    printf '  %s\n' $found
    exit 1
  fi

  echo "No Brewfile for $(hostname). Which one should it start from?"
  PS3="Brewfile: "
  select choice in $hosts; do
    [[ -n "$choice" ]] && break
    echo "Pick a number from the list."
  done

  if [[ -z "$choice" ]]; then
    echo "No Brewfile chosen; nothing to install."
    exit 1
  fi

  mkdir -p "${HOMEBREW_BUNDLE_FILE:h}"
  cp "$DOTFILES/$choice/Brewfile" "$HOMEBREW_BUNDLE_FILE"
  echo "Copied $choice's Brewfile to $HOMEBREW_BUNDLE_FILE"
fi

export HOMEBREW_BUNDLE_FILE
echo "Using Brewfile: $HOMEBREW_BUNDLE_FILE"

brew bundle --verbose
