# dotfiles

I **_learned_** about dotfiles at [dotfiles.eieio.xyz](http://dotfiles.eieio.xyz), and so can you!

## Decommission Computer

[Create a bootable USB installer for macOS](https://support.apple.com/en-us/HT201372).

Software audit:

- Uninstall unwanted software (e.g. GarageBand, iMovie, Keynote, Numbers, Pages)
- Install missing software (look at `/Applications`, panes in System Preferences , maybe `~/Applications`, etc.)

Backup / sync files:

- Commit and Push to remote repositories
- Run `code --list-extensions > vscode_extensions` from `~/.dotfiles` to export [VS Code extensions](vscode_extensions)
- Time Machine
- Dropbox / Google Drive
- Manual Backups (external drives, redundant cloud services)
- Contacts, Photos, Calendar, Messages (Google, iCloud)
- etc.

Deactivate licenses:

- Dropbox (`Preferences > Account > Unlink`)
- Sign Out of App Store (`Menu > Store > Sign Out`)
- iTunes, etc.

## Restore Instructions

0. Take note of the hostname - `sudo scutil --set HostName somehost.local`
1. `xcode-select --install` (Command Line Tools are required for Git and Homebrew)
2. `git clone https://github.com/sidouglas/dotfiles.git ~/.dotfiles`. We'll start with `https` but switch to `ssh` after everything is installed.
3. `cd ~/.dotfiles`
4. If necessary, `git checkout <another_branch>`.
5. Do one last Software Audit by editing your Brewfile directly.
6. [`./install`](install)
7. Restart computer.
8. Setup up Dropbox (use multifactor authentication!) and allow files to sync before setting up dependent applications. Alfred settings are stored here. backup depends on this as well (and thus so do Terminal and VS Code).
9. Run `backup restore`. Consider doing a `backup restore --dry-run --verbose` first.
10. [Generate ssh key](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh), add to GitHub, and switch remotes.

    ```zsh
    # Generate SSH key in default location (~/.ssh/config)
    ssh-keygen -t ed25519 -C "1107946+sidouglas@users.noreply.github.com"

    # Start the ssh-agent
    eval "$(ssh-agent -s)"

    # Create config file with necessary settings
    Other configs are saved in bitwarden.
    << EOF > ~/.ssh/config
    Host *
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/github
    EOF

    # Add private key to ssh-agent
    ssh-add -K ~/.ssh/github

    # Copy public key and add to github.com > Settings > SSH and GPG keys
    pbcopy < ~/.ssh/github

    # Test SSH connection, then verify fingerprint and username
    # https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection
    ssh -T git@github.com

    # Switch from HTTPS to SSH
    git remote set-url origin git@github.com:sidouglas/dotfiles_macos.git
    ```

### Resources

- https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f
