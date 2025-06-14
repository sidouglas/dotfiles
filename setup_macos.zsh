#!/usr/bin/env zsh

echo "\n<<< Starting macOS Setup >>>\n"

osascript -e 'tell application "System Preferences" to quit'

# Make everything tabable in Finder
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# We need to see all files
defaults write com.apple.Finder AppleShowAllFiles true

# Finder > Preferences > General > New Finder windows show:
defaults write com.apple.finder NewWindowTarget -string 'PfLo'
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/.dotfiles"

# System Preferences > Dock
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 45
defaults write com.apple.dock largesize -int 60
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.dock autohide-delay -float 0.1
defaults write com.apple.dock orientation -string "left";


# System Preferences > Accessibility > Pointer Control > Mouse & Trackpad > Trackpad Options > Enable Dragging > Three Finger Drag (NOTE: The GUI doesn't update)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Third-Party Software

# From https://gist.github.com/devnoname120/4767a0aa18879217170fd0c68809fc24
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# Disable Anki from Sleeping
# https://github.com/FooSoft/anki-connect
defaults write net.ankiweb.dtop NSAppSleepDisabled -bool true
defaults write net.ichi2.anki NSAppSleepDisabled -bool true
defaults write org.qt-project.Qt.QtWebEngineCore NSAppSleepDisabled -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false              # For VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false      # For VS Code Insider
defaults write com.vscodium ApplePressAndHoldEnabled -bool false                      # For VS Codium
defaults write com.microsoft.VSCodeExploration ApplePressAndHoldEnabled -bool false   # For VS Codium Exploration users
defaults delete -g ApplePressAndHoldEnabled                                           # If necessary, reset global default

# Keyboard Maestro notifications
defaults write com.stairways.keyboardmaestro.engine "Notification-Information" -bool YES
defaults write com.stairways.keyboardmaestro.engine "Notification-MacroExecution" -bool NO
defaults write com.stairways.keyboardmaestro.engine "Notification-MacroCancelled" -bool YES
defaults write com.stairways.keyboardmaestro.engine "Notification-ActionFailed" -bool YES
defaults write com.stairways.keyboardmaestro.engine "Notification-ReceivedClipboard" -bool YES

# Stop terminal from going into Secure input mode
defaults write com.apple.Terminal SecureKeyboardEntry -bool false

# Finish macOS Setup
killall Finder
killall Dock
echo "\n<<< macOS Setup Complete.
    A logout or restart might be necessary. >>>\n"
