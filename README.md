<h1 align="center">
  <a href="https://github.com/fr0st-iwnl/sh-toolbox" target="_blank"><img src="https://github.com/fr0st-iwnl/assets/blob/main/thumbnails/sh-toolbox/sh-toolbox-40px.png" alt="sh-toolbox" width="900"></a>
</h1>
<p align="center"><strong>A collection of useful <code>.sh</code> scripts for daily use across various Linux distributions and desktop environments.</strong></p>


<p align="center">
<a href="#-installation">Installation</a> •
<a href="#-features">Features</a> •
  <a href="#-script-collection">Script Collection</a> •
<a href="#-keybindings">Keybindings</a>
</p>


## ✨ Features

- **Works Everywhere:**
  - Runs on most Linux systems without problems

- **Easy to Use:**
  - Quick setup with just a few commands
  - Consistent UI with helpful notifications
  - Simple, clean code

- **Pick What You Need:**
  - Use only the scripts you want
  - Easy to change for your needs
  - Light on system resources

- **Set It and Forget It:**
  - Automate routine tasks with minimal configuration
  - Works well with keyboard shortcuts
  - Flexible enough to fit into your existing workflow




## 📦 Installation
<!---First git clone the repository.
```
git clone https://github.com/fr0st-iwnl/sh-toolbox.git
```
-Then run these commands in your terminal.--->
To get started with `sh-toolbox`, simply run the commands below:
```bash
git clone https://github.com/fr0st-iwnl/sh-toolbox.git
cd sh-toolbox
chmod +x sh-toolbox.sh
./sh-toolbox.sh -i
./sh-toolbox.sh -c
```
After running these commands, you'll be ready to use the toolbox!


## 🔧 Script Collection

- `1`. [quote.sh](https://github.com/fr0st-iwnl/sh-toolbox/tree/master/Quotes#-quotesh) - A simple quote script that displays a random quote in the terminal.
- `2`. [update.sh](https://github.com/fr0st-iwnl/sh-toolbox/tree/master/System%20Update#-updatesh) - A simple script for managing system updates across various **Linux distributions**, including support for `AUR`, `Flatpak`, and `common package managers`.
- `3`. [weather.sh](https://github.com/fr0st-iwnl/sh-toolbox/tree/master/Weather#-weathersh) - A simple weather script that fetches the current weather for a specified location or auto-detects it based on your **IP** and sends a desktop notification using data from [wttr.in](https://wttr.in/).
- `4`. [netinfo.sh](https://github.com/fr0st-iwnl/sh-toolbox/tree/master/NetInfo#-netinfosh) - A simple script that displays detailed network information, including IP addresses, connection latency, and internet speeds in the terminal using `speedtest-cli`.
- `5`. [random-wall.sh](https://github.com/fr0st-iwnl/sh-toolbox/tree/master/Random%20Wallpaper#-random-wallsh) - A simple script to display random wallpapers from a specified directory.
- `6`. [remind-me.sh](https://github.com/fr0st-iwnl/sh-toolbox/blob/master/Remind%20Me/README.md#-remind-mesh) - A script to set reminders with notifications and sound

## 🎹 Keybindings

The `keybind.sh` script is something special! It makes setting up keyboard shortcuts super easy. With this simple tool, you can:

- Add custom keyboard shortcuts for any command
- Manage all your shortcuts in one place
- Get notifications when shortcuts are triggered
- Works perfectly with the audio control scripts

To load the default **sh-toolbox** keybindings, run: `keybind load`

- `toggle_mic.sh` - Mutes/Unmutes your mic on **Insert**
- `toggle_audio.sh` - Mutes/Unmutes your audio on **Pause/Break**
- `volume_up.sh` - Increases audio volume by 5% on **Ctrl + Shift + Up**
- `volume_down.sh` - Decreases audio volume by 5% on **Ctrl + Shift + Down**


Use `keybind add` to create a shortcut, and `keybind list` to view all your bindings.
<br>
<br>
For more details, read the full documentation on this tool.

