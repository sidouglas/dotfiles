#!/usr/bin/env zsh
echo "Enter superuser password to edit /etc/shells"
echo $HOMEBREW_PREFIX/bin/zsh | sudo tee -a '/etc/shells'

# see https://apple.stackexchange.com/a/442468 is this does not work.
echo "Enter user password to change login shell"
chsh -s $HOMEBREW_PREFIX/bin/zsh

# https://ohmyz.sh/#install
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

sed -i '' 's/(git)/(\
git\
nvm\
zsh-autosuggestions\
)/g' ~/.dotfiles/zshrc

# Vendor specific or private
echo 'ZSH_SHARED=~/Google\ Drive/My\ Drive/shared/.zsh_shared' >> ~/.zshrc
echo 'if [ -f $ZSH_SHARED ];' >> ~/.zshrc
echo 'then' >> ~/.zshrc
echo '  source $ZSH_SHARED' >> ~/.zshrc
echo 'fi' >> ~/.zshrc
