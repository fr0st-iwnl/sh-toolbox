# 📦 random-wall.sh

A simple script to display random wallpapers from a specified directory.

## 🎬 Showcase

https://github.com/user-attachments/assets/89c4cfca-2b2f-496b-9add-d4f5b5ca78e2

## ✨ Features
- **Randomly selects wallpapers from a specified directory**
- **Customizable wallpaper directory path**
- **Displays preview in terminal** (if terminal supports image display)
- **Sets wallpaper using:**
  - **feh** (for minimal window managers)
  - **gsettings** (for GNOME)
  - **xfconf-query** (for XFCE)
  - **plasma-apply-wallpaperimage** (for KDE Plasma)



## 📝 Command Options

-  `-h`, `--help`     Show the help message
-  `-p`, `--path`     Specifies the path to wallpapers directory
-  `-s`, `--show`     Show the selected wallpaper in terminal **(if supported)**




## 📦 Installation

Just download the `.sh` script or follow the steps in the [Installation](https://github.com/fr0st-iwnl/sh-toolbox?tab=readme-ov-file#-installation) section.

## 🧭 Steps to Create the Custom Command [MANUAL]


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `random-wall.sh` script there and rename it to `random-wall` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/random-wall.sh ~/.local/share/bin/random-wall
   ```

1. **Make `random-wall` executable**  
   Give the `random-wall` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/random-wall
   ```

**random-wall Your Shell Configuration:**
Add the following line to your `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/.local/share/bin:$PATH"
```

**Reload Your Terminal:**
Run the following command to apply the changes:

```bash
source ~/.bashrc
```
**or**

```bash
source ~/.zshrc
``` 
   

   
