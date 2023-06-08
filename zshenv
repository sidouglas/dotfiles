echo '.zshenv loaded'
function exists() { command -v $1 > /dev/null 2>$1 }

export NVM_DIR="$HOME/.nvm"

if [[ $(uname -m) == "arm64" ]]; then
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
else
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

autoload zmv #filename manipulation tool.

# RVM can encounter errors if it's not the last thing in .bash_profile
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to path for scripting (to manage Ruby versions)
export PATH="$GEM_HOME/bin:$PATH"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # Load RVM into a shell session *as a function*
export PATH="$PATH:$HOME/.dotfiles/bin"
