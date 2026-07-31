# LaunchAgents

Personal `launchd` background agents. The real files live here in the dotfiles
repo; dotbot symlinks each plist into `~/Library/LaunchAgents/` (where launchd
requires them) via `install.conf.yaml`.

---

## `com.simondouglas.yeti-input` — pin audio input to the Yeti Nano

**Problem it solves:** When the SiXM6 Bluetooth headphones connect/reconnect,
macOS grabs their mic as the default input. This forces the input back to the
**Yeti Nano** whenever the Yeti is plugged in. Output (headphone playback) is
never touched.

**How it works:**
- `bin/force-yeti-input` — checks every run: if the Yeti Nano is connected and
  isn't already the input, switch input to it. Does nothing when the Yeti is
  unplugged, so the headset/built-in mic still work normally.
- The plist runs that script at login and every **3 seconds** (`StartInterval`),
  so it self-corrects within moments of the headphones reconnecting.
- Errors (if any) log to `~/Library/Logs/yeti-input.log`.

### Prerequisites (per machine — can't live in the repo)

```bash
brew install switchaudio-osx        # provides /opt/homebrew/bin/SwitchAudioSource
```

### Enable / load

Symlink is created by dotbot (`cd ~/.dotfiles && ./install`). Then:

```bash
launchctl load ~/Library/LaunchAgents/com.simondouglas.yeti-input.plist
```

### Disable / pause (e.g. when you DO want the headset mic)

```bash
launchctl unload ~/Library/LaunchAgents/com.simondouglas.yeti-input.plist
# re-enable later with `launchctl load ...`
```

### Check status

```bash
launchctl list | grep yeti-input          # 2nd column = last exit code (0 = ok)
SwitchAudioSource -c -t input             # what the current input actually is
SwitchAudioSource -a -t input             # list all available inputs
```

### Change the preferred device or poll interval

- Preferred device: edit `PREFERRED` in `bin/force-yeti-input`.
- Poll interval: edit `<integer>3</integer>` under `StartInterval` in the plist,
  then `unload` + `load` to apply.

> Device names must match exactly what `SwitchAudioSource -a -t input` prints.
