# 🛜 netinfo.sh

A simple script that displays detailed network information, including IP addresses, connection latency, and internet speeds in the terminal using `speedtest-cli`.

## 🎬 Showcase

https://github.com/user-attachments/assets/fe2d67e9-17de-4170-8b08-7fedc84137c0

## ✨ Features

- **Displays detailed network information:**
  - `Public IP address` (optional)
  - `Local IP address`
  - `Network interface details`
  - `Connection latency`
- **Internet speed test** (using speedtest-cli)
  - `Download speed`
  - `Upload speed`
  - `Ping*`
- **Desktop notifications** for test results
- **Quick mode** for basic info only
- **Clean, minimal output formatting**



## 📝 Command Options

### Options:
-  `--help, -h`            Show the help message
-  `--show-ip, -s`         Show public IP address (hidden by default)
-  `--quick, -q`           Show only basic information (no speed test)
-  `--no-notify, -n`         Disable desktop notification

## 📦 Installation

Just download the `.sh` script or follow the steps in the [Installation](https://github.com/fr0st-iwnl/sh-toolbox?tab=readme-ov-file#-installation) section.

## 🧭 Steps to Create the Custom Command [MANUAL]


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `netinfo.sh` script there and rename it to `netinfo` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/netinfo.sh ~/.local/share/bin/netinfo
   ```

1. **Make `netinfo` executable**  
   Give the `netinfo` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/netinfo
   ```

**Update Your Shell Configuration:**
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
   

   
