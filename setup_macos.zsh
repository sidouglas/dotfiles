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

# System Settings > Trackpad > Point & Click > Tap to click (single-finger tap).
# Built-in trackpad, Bluetooth trackpad, and the global key the login window and
# other processes read. tapBehavior lives in the per-host domain.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# System Settings > Trackpad > Scroll & Zoom > Natural scrolling.
# false = inverted/traditional: content goes the opposite way to your fingers.
# This key is global, so it flips scrolling for any mouse too. Takes effect on
# next login, not from `killall Dock`.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# System Settings > Keyboard > Input Sources > Edit > Use smart quotes and dashes.
# One checkbox in the GUI, two keys underneath. Off means straight quotes and
# plain hyphens, which is what you want anywhere near code.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# System Settings > Keyboard > Keyboard Shortcuts > Screenshots.
# Unticks all five, freeing Cmd-Shift-3/4/5 for a third-party capture tool.
# IDs: 28/29 whole screen to file/clipboard, 30/31 selected area to
# file/clipboard, 184 the screenshot-and-recording palette.
# -dict-add replaces the whole entry, so the stored key binding is dropped along
# with the enabled flag. Re-ticking one in the GUI reassigns the default key, so
# nothing is lost permanently.
for _shortcut in 28 29 30 31 184; do
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$_shortcut" \
    '<dict><key>enabled</key><false/></dict>'
done
unset _shortcut

# Screenshot capture behaviour. The shortcuts above are off, but these still
# apply to `screencapture`, Preview > Take Screenshot, and any tool shelling out
# to the system capture.
defaults write com.apple.screencapture show-thumbnail -bool false   # no floating preview
defaults write com.apple.screencapture disable-shadow -bool true    # no window drop shadow
defaults write com.apple.screencapture include-date -bool false     # plain "Screenshot.png"
defaults write com.apple.screencapture type -string "png"
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"

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
# If necessary, reset global default. Errors with "Domain not found" when the
# key was never set, which is the normal case on a fresh machine.
defaults delete -g ApplePressAndHoldEnabled 2>/dev/null || true

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
killall SystemUIServer                                              # picks up com.apple.screencapture
# Reloads the keyboard shortcut table so the screenshot hotkeys go away without
# a logout. Private framework, so tolerate it being missing.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
echo "\n<<< macOS Setup Complete.
    A logout or restart might be necessary. >>>\n"
