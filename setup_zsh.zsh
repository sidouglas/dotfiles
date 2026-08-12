#!/usr/bin/env zsh
echo "\n<<< Starting ZSH Setup >>>\n"

# Installation unnecessary; it's in the Brewfile.

# https://stackoverflow.com/a/4749368/1341838
#if grep -Fxq '/usr/local/bin/zsh' '/etc/shells'; then
#  echo '/usr/local/bin/zsh already exists in /etc/shells'
#else
#  echo "Enter superuser (sudo) password to edit /etc/shells"
#  echo '/usr/local/bin/zsh' | sudo tee -a '/etc/shells' >/dev/null
#fi


#if [ "$SHELL" = '/usr/local/bin/zsh' ]; then
#  echo '$SHELL is already /usr/local/bin/zsh'
#else
#  echo "Enter user password to change login shell"
#  chsh -s '/usr/local/bin/zsh'
#fi


#if sh --version | grep -q zsh; then
#  echo '/private/var/select/sh already linked to /bin/zsh'
#else
#  echo "Enter superuser (sudo) password to symlink sh to zsh"
#  # Looked cute, might delete later, idk
#  sudo ln -sfv /bin/zsh /private/var/select/sh

  # I'd like for this to work instead.
  # sudo ln -sfv /usr/local/bin/zsh /private/var/select/sh
#fi

# https://ohmyz.sh/#install
# --keep-zshrc matters: without it the installer replaces the ~/.zshrc symlink
# that dotbot just created with its own copy.
if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
  echo "oh-my-zsh already installed, skipping"
else
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# Anything in zshrc's plugins=() that doesn't ship with oh-my-zsh has to be
# cloned here, or zsh prints "[oh-my-zsh] plugin '...' not found" on every
# shell start and the plugin silently does nothing. Keep this in step with
# the plugins=() list in zshrc.
typeset -A ZSH_PLUGIN_REPOS=(
  zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
  zsh-vim-mode        https://github.com/softmoth/zsh-vim-mode
)

ZSH_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
for name url in ${(kv)ZSH_PLUGIN_REPOS}; do
  if [[ -d "$ZSH_PLUGINS/$name" ]]; then
    echo "$name already cloned, skipping"
  else
    git clone "$url" "$ZSH_PLUGINS/$name"
  fi
done
