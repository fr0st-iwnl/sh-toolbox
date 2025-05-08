# 🎹 keybind.sh

A simple tool to manage keyboard shortcuts on Linux using `sxhkd`, working with both **X11** and **Wayland**. Easily set up key combos for any command you want.

## 🎬 Showcase

**[❗]** This video runs the version `1.0` so it’s a bit outdated.

https://github.com/user-attachments/assets/37799c45-7aa3-4915-95ce-ef5ab9d5c3b6


## ✨ Features

- **Simple Interface:** Easy-to-use commands for managing keyboard shortcuts
- **Notification Support:** Optional desktop notifications when shortcuts are triggered
- **Audio Controls:** Pre-configured shortcuts for audio management


## 🚀 Getting Started

1. Make sure `sxhkd` is installed:
   ```bash
   # Arch Linux
   sudo pacman -S sxhkd
   
   # Debian/Ubuntu
   sudo apt install sxhkd
   
   # Fedora
   sudo dnf install sxhkd
   ```

2. Done! Now run `keybind help`

## 📝 Command Options

### Usage:


`keybind` [command]

### Commands:
-  `list`        - List all configured keybindings
-  `add`         - Add a new keybinding
-  `remove`      - Remove a keybinding
-  `load`        - Load sh-toolbox default keybindings
-  `reload`      - Reload sxhkd configuration
-  `startup`     - Configure sxhkd startup options
-  `help`        - Display this help information

## ⌨️ Default sh-toolbox Keybindings

By default, the `keybind.sh` script includes optional audio control scripts that support both **Pipewire** and **PulseAudio**. When you run keybind load, the following keybindings are automatically set up:

| Key Combination | Action | Script |
|----------------|--------|--------|
| `Insert` | Toggle microphone mute | `toggle_mic.sh` |
| `Pause` | Toggle audio mute | `toggle_audio.sh` |
| `Ctrl + Shift + Up` | Increase volume by 5% | `volume_up.sh` |
| `Ctrl + Shift + Down` | Decrease volume by 5% | `volume_down.sh` |

## ⚙️ Configure Sxhkd Startup 

Run `keybind startup` and select an option from the menu:

**Options:**
  <br>
&nbsp;&nbsp;&nbsp;  `1` - Enable sxhkd startup on login
  <br>
&nbsp;&nbsp;&nbsp;   `2` - Disable sxhkd startup on login
  <br>
&nbsp;&nbsp;&nbsp;   `q` - Return to main menu

*Note: This works only with systems using `systemd`.*




## ⚙️ Configuration

The configuration files are stored in:
- `~/.config/sh-toolbox/keybinds.conf` - Your keybinding definitions **(Use this file to configure your keybindings)**
<br> After making changes, don't forget to run `keybind reload` to apply the new configuration.
- `~/.config/sxhkd/sxhkdrc` - The generated sxhkd configuration

## 🔗 Dependencies

- **[sxhkd](https://github.com/baskerville/sxhkd)**: Simple X hotkey daemon
