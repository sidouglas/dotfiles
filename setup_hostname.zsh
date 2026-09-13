#!/usr/bin/env zsh

echo "\n<<< Starting Hostname Setup >>>\n"

# macOS keeps three names and they drift apart easily:
#
#   ComputerName   the friendly name in Sharing prefs ("Simon's MacBook Pro")
#   LocalHostName  the Bonjour name, letters/digits/hyphens only
#   HostName       what `hostname` actually returns
#
# setup_homebrew.zsh looks for $DOTFILES/$(hostname)/Brewfile, so an unset or
# junk HostName silently forks a Brewfile directory for a name you never chose.
# This runs before it so the name is settled first.
#
# Name comes from, in order:
#   ./setup_hostname.zsh my-machine   argument
#   DOTFILES_HOSTNAME=my-machine      environment
#   otherwise it asks, and leaving the prompt blank changes nothing

desired="${1:-$DOTFILES_HOSTNAME}"

current_computer=$(scutil --get ComputerName 2>/dev/null)
current_local=$(scutil --get LocalHostName 2>/dev/null)
current_host=$(scutil --get HostName 2>/dev/null)

if [[ -z "$desired" ]]; then
  # Nothing requested and the three names already agree: there is nothing to do,
  # and ./install shouldn't nag on every single run.
  if [[ -n "$current_host" \
     && "$current_computer" == "$current_host" \
     && "$current_local" == "${current_host//[^a-zA-Z0-9-]/-}" ]]; then
    echo "Hostname is $current_host and all three names agree, skipping"
    exit 0
  fi

  if [[ ! -t 0 ]]; then
    echo "No name given and no terminal to ask on; leaving HostName as ${current_host:-unset}."
    echo "Set one with: ./setup_hostname.zsh <name>"
    exit 0
  fi

  echo "These names don't agree, which is how a stray Brewfile directory appears:"
  echo "  ComputerName   ${current_computer:-(unset)}"
  echo "  LocalHostName  ${current_local:-(unset)}"
  echo "  HostName       ${current_host:-(unset)}"
  echo
  read "desired?Hostname to use (blank to leave alone): "
fi

if [[ -z "$desired" ]]; then
  echo "Left the hostname alone."
  exit 0
fi

# LocalHostName is a Bonjour name and rejects anything outside [A-Za-z0-9-],
# so dots in a name like simon.douglas.streem have to become hyphens.
local_name="${desired//[^a-zA-Z0-9-]/-}"

if [[ "$local_name" != "$desired" ]]; then
  echo "Note: LocalHostName can't hold '$desired', using '$local_name' for it."
fi

if [[ "$current_computer" == "$desired" \
   && "$current_local" == "$local_name" \
   && "$current_host" == "$desired" ]]; then
  echo "Hostname is already $desired, skipping"
  exit 0
fi

echo "Setting hostname to $desired"
echo "This needs sudo."

if ! sudo scutil --set ComputerName "$desired" \
  || ! sudo scutil --set LocalHostName "$local_name" \
  || ! sudo scutil --set HostName "$desired"; then
  echo "\nCouldn't set the hostname."
  echo "Run it yourself, then re-run ./install:"
  echo "  sudo scutil --set ComputerName  $desired"
  echo "  sudo scutil --set LocalHostName $local_name"
  echo "  sudo scutil --set HostName      $desired"
  exit 1
fi

dscacheutil -flushcache

echo "Hostname is now $(hostname)"

# The Brewfile directory is keyed off the new name, so point out the mismatch
# rather than silently letting setup_homebrew.zsh fork a fresh one.
DOTFILES="${0:a:h}"
if [[ ! -f "$DOTFILES/$desired/Brewfile" ]]; then
  echo "\nNo Brewfile at $DOTFILES/$desired/Brewfile yet."
  if [[ -n "$current_host" && -d "$DOTFILES/$current_host" ]]; then
    echo "The old name still has one. To carry it over:"
    echo "  mv '$DOTFILES/$current_host' '$DOTFILES/$desired'"
  else
    echo "setup_homebrew.zsh will offer to start from another machine's."
  fi
fi
