# 🔍 private-search.sh

A script to install and configure a private search engine like [SearXNG](https://github.com/searxng/searxng) and [Whoogle](https://github.com/benbusby/whoogle-search) with **Docker**.

## 🎬 Showcase

https://github.com/user-attachments/assets/8ebec02e-805a-4fdf-841e-25b0b1e1c9e7

## ✨ Features

- Lets you choose and install private search engines: **SearXNG** or **Whoogle**
- Prompts you for `IP address` and `port` to set up the service as you prefer
- Includes `-r` flag to **remove** the installed search engine container, image, and configuration
- Adds a **symlink** to ensure the setup works even if Wi-Fi or Ethernet isn't available at startup
- Easy to re-run and reconfigure any time



## 📝 Command Options

### Options:
-  `-h`  Display this help message
-  `-r`  Remove installed search engine container, image, and configuration

## 📦 Installation

Just download the `.sh` script or follow the steps in the [Installation](https://github.com/fr0st-iwnl/sh-toolbox?tab=readme-ov-file#-installation) section.

## 🧭 Steps to Create the Custom Command [MANUAL]


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `private-search.sh` script there and rename it to `private-search` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/private-search.sh ~/.local/share/bin/private-search
   ```

1. **Make `private-search` executable**  
   Give the `private-search` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/private-search
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
   

   

