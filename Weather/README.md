# ⛅ weather.sh

A simple weather script that fetches the current weather for a specified location or auto-detects it based on your IP and sends a desktop notification using data from [wttr.in](https://wttr.in/).

## 🎬 Showcase

https://github.com/user-attachments/assets/fc9912ce-ca7b-4aae-9679-b46d0c38076a


## ✨ Features

- **Fetches weather data from wttr.in:**
  - **Current conditions**
  - **Temperature**
  - **Precipitation**
  - **Wind speed and direction**
- **Multiple forecast types:**
  - **Simple** (basic current conditions)
  - **Detailed** (comprehensive weather data)
  - **3-day forecast**
- **Location options:**
  - **Auto-detection** based on IP
  - **Manual location** specification
  - **Privacy mode** to hide location details
- **Customizable units** (Celsius/Fahrenheit)
- **Desktop notifications** with weather updates
- **Clean, minimal output formatting**




## 📝 Command Options

### Options:
-  `--location, -l`        Specify a location (city, airport code, etc.)
-  `--type, -t`            Forecast type: **simple**, **detailed**, **3day** (default: simple)
-  `--privacy, -p`         Enable privacy mode **(hide location information)**
-  `--units, -u`           Temperature units: `C` for Celsius, `F` for Fahrenheit (default: C)
-  `--no-notify, -n`       Disable desktop notifications **(notify-send required)**
-  `--help, -h`            Show this help message

### Examples:
   - **weather.sh**                                `#` Current location, simple forecast
   - **weather.sh --location London**              `#` Weather in London
   - **weather.sh --type detailed**                `#` Detailed weather information
   - **weather.sh --location Tokyo --type 3day**   `#` 3-day forecast for Tokyo
   - **weather.sh --privacy**                     `#` Hide location information
   - **weather.sh --units F**                      `#` Show temperature in Fahrenheit
   - **weather.sh --no-notify**                    `#` Disable desktop notifications (notify-send required)


## 📦 Installation

Just download the `.sh` script or follow the steps in the [Installation](https://github.com/fr0st-iwnl/sh-toolbox?tab=readme-ov-file#-installation) section.

## 🧭 Steps to Create the Custom Command [MANUAL]


1. **Create the `bin` Directory**  
   Create a folder called `bin` in `~/.local/share/`. If it already exists, simply add the `weather.sh` script there and rename it to `weather` (removing the `.sh` extension).

   ```bash
   mkdir -p ~/.local/share/bin
   cp /path/to/weather.sh ~/.local/share/bin/weather
   ```

1. **Make `weather` executable**  
   Give the `weather` permissions to run.

   ```bash
   chmod +x ~/.local/share/bin/weather
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
   

   
