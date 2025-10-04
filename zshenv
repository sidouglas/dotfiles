# echo '.zshenv loaded'
function exists() { command -v $1 > /dev/null 2>$1 }

export NVM_DIR="$HOME/.nvm"

[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

autoload zmv #filename manipulation tool.

PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$PATH:$HOME/.dotfiles/bin"
export PATH="/usr/local/opt/mysql/bin:$PATH"

export JAVA_HOME=/opt/homebrew/opt/openjdk@21
export PATH=$JAVA_HOME/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
