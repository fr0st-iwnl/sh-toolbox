# 💭 quote.sh

A simple quote script that displays a random quote in the terminal.

## 🎬 Showcase

https://github.com/user-attachments/assets/bc631024-b94a-49a6-bbd4-33ae94b9aece


## ✨ Features

- **Displays random quotes**
- **Clean, minimal output formatting**



## 📦 Installation

Just download the `.sh` script or follow the steps in the [Installation](https://github.com/fr0st-iwnl/sh-toolbox?tab=readme-ov-file#-installation) section.

## 🧭 Steps to Create the Custom Command [MANUAL]


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `quote.sh` script there and rename it to `quote` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/quote.sh ~/.local/share/bin/quote
   ```

1. **Make `quote` executable**  
   Give the `quote` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/quote
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
   

   
