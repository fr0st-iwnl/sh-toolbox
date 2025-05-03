# 📦 update.sh

A simple script for managing updates on Arch-based distributions, including AUR and Flatpak support.

## 🎬 Showcase

https://github.com/user-attachments/assets/b99df5cd-1c42-4ad1-9dc3-0ef782d53a96


## ✨ Features


- Checks for updates in:
  - Official Arch repositories
  - AUR (using yay or paru)
  - Flatpak
- User confirmation before proceeding with updates
- Outputs the number of available updates in a clear format


## 📦 Installation

Just download the `.sh` script or `git clone` the repo.

## 🧭 Steps to Create the Custom Command


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `update.sh` script there and rename it to `update` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/update.sh ~/.local/share/bin/update
   ```

1. **Make `update` executable**  
   Give the `update` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/update
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
   
   

   
