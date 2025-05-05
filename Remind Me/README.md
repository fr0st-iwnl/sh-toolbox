# ⏰ remind-me.sh

A script to set reminders with notifications and sound

## 🎬 Showcase

https://github.com/user-attachments/assets/b17fc03c-44db-429b-8da0-38150ea37f23


## ✨ Features

- **Set reminders with custom messages and durations**
- **Flexible time format support:**
  - Simple minutes/hours (e.g., 5m, 2h)
  - Complex combinations (e.g., 1h 30m 45s)
- **Multiple notification methods:**
  - Visual alerts with flashing text
  - Audio alerts using various sound methods:
    - **System beep**
    - **PulseAudio**
    - **ALSA**
    - **Speaker-test**
    - **Mplayer**
- **Persistent reminders that continue until dismissed**

## 📝 Command Options

- `-h`, `--help`    Show the help message
-  `-b`, `--background`: Set a reminder that runs in the background
-  `list`:        List all active background reminders
-  `stop` <id>:    Stop a specific background reminder
-  `stop-all`:     Stop all background reminders



## 📦 Installation

Just download the `.sh` script or follow the steps in the [Installation](https://github.com/fr0st-iwnl/sh-toolbox?tab=readme-ov-file#-installation) section.

## 🧭 Steps to Create the Custom Command [MANUAL]


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `remind-me.sh` script there and rename it to `remind-me` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/remind-me.sh ~/.local/share/bin/remind-me
   ```

1. **Make `remind-me` executable**  
   Give the `remind-me` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/remind-me
   ```

**remind-me Your Shell Configuration:**
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
   

   
