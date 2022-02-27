#!/usr/bin/env zsh

# https://ohmyz.sh/#install
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# Vendor specific or private
echo 'ZSH_SHARED="~/Google Drive/My Drive/shared/.zsh_shared"' >> ~/.zshrc
echo 'if [ -f $ZSH_SHARED ];' >> ~/.zshrc
echo 'then' >> ~/.zshrc
echo '  source $ZSH_SHARED' >> ~/.zshrc
echo 'fi' >> ~/.zshrc
