#!/bin/bash

# weather.sh
#
# A simple weather script that displays the weather for a given location
# and sends desktop notifications with the weather information.
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issue: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Request: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------



# Default location (empty for auto-detect)
LOCATION="" # empty for auto-detect by IP but u can specify a location if u want
FORECAST_TYPE="simple" # simple, detailed, 3day
PRIVACY_MODE="off" # on, off
TEMP_UNIT="C"  # C, F
NOTIFICATIONS="on"  # on, off

# Colors :)
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"

# Echo Command Line Arguments
show_help() {
  echo
  echo -e "${BOLD}Usage:${RESET} $(basename "$0") [options]"
  echo 
  echo -e "${BOLD}Options:${RESET}"
  echo -e "  ${GREEN}--location, -l${RESET}        Specify a location (city, airport code, etc.)"
  echo -e "  ${GREEN}--type, -t${RESET}            Forecast type: simple, detailed, 3day (default: simple)"
  echo -e "  ${GREEN}--privacy, -p${RESET}         Enable privacy mode (hide location information)"
  echo -e "  ${GREEN}--units, -u${RESET}           Temperature units: C for Celsius, F for Fahrenheit (default: C)"
  echo -e "  ${GREEN}--no-notify, -n${RESET}       Disable desktop notifications (notify-send required)"
  echo -e "  ${GREEN}--help, -h${RESET}            Show this help message"
  echo
  echo -e "${BOLD}Examples:${RESET}"
  echo -e "  ${CYAN}$(basename "$0")${RESET}                                # Current location, simple forecast"
  echo -e "  ${CYAN}$(basename "$0") --location London${RESET}              # Weather in London"
  echo -e "  ${CYAN}$(basename "$0") --type detailed${RESET}                # Detailed weather information"
  echo -e "  ${CYAN}$(basename "$0") --location Tokyo --type 3day${RESET}   # 3-day forecast for Tokyo"
  echo -e "  ${CYAN}$(basename "$0") --privacy${RESET}                      # Hide location information"
  echo -e "  ${CYAN}$(basename "$0") --units F${RESET}                      # Show temperature in Fahrenheit"
  echo -e "  ${CYAN}$(basename "$0") --no-notify${RESET}                    # Disable desktop notifications (notify-send required)"
  echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --location|-l)
      LOCATION="$2"
      shift 2
      ;;
    --type|-t)
      FORECAST_TYPE="$2"
      shift 2
      ;;
    --privacy|-p)
      PRIVACY_MODE="on"
      shift
      ;;
    --units|-u)
      TEMP_UNIT="$2"
      if [[ ! "$TEMP_UNIT" =~ ^[CcFf]$ ]]; then
        echo -e "${RED}Error:${RESET} Invalid temperature unit '$TEMP_UNIT'"
        echo -e "Valid units are: ${GREEN}C${RESET} (Celsius) or ${GREEN}F${RESET} (Fahrenheit)"
        exit 1
      fi
      TEMP_UNIT="${TEMP_UNIT^^}"
      shift 2
      ;;
    --no-notify|-n)
      NOTIFICATIONS="off"
      shift
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}Error:${RESET} Unknown option '$1'"
      show_help
      exit 1
      ;;
  esac
done

valid_types=("simple" "detailed" "3day")
if [[ ! " ${valid_types[*]} " =~ " ${FORECAST_TYPE} " ]]; then
  echo -e "${RED}Error:${RESET} Invalid forecast type '${FORECAST_TYPE}'"
  echo -e "Valid types are: ${GREEN}${valid_types[*]}${RESET}"
  exit 1
fi

if [ -n "$LOCATION" ]; then
  LOC_PARAM="$LOCATION"
else
  # For auto-detect, use IP location
  LOC_PARAM="~"  # This tells wttr.in to use IP-based location
fi

# Set temperature unit param for wttr.in
# For wttr.in, use 'u' in the URL for Fahrenheit
UNITS_PARAM=""
if [ "$TEMP_UNIT" = "F" ]; then
  UNITS_PARAM="u"
fi

# Get weather from wttr.in based on forecast type
case "$FORECAST_TYPE" in
  simple)
    weather=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=1")       # e.g. "🌦 +18°C"
    forecast=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=3")      # e.g. "YourCity: 🌦 +18°C"
    ;;
  detailed)
    weather=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=1")
    forecast=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=3")
    details=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%c+%t+%w+%h+%m" | sed 's/+/ /g')
    condition=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%C")    # Weather condition description
    ;;
  3day)
    weather=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=1")
    forecast=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=3")
    
    # Get better 3-day forecast with actual days
    today=$(date +%a)
    tomorrow=$(date -d "tomorrow" +%a)
    day_after=$(date -d "2 days" +%a)
    
    # Get weather condition descriptions
    day1_condition=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%C" | sed 's/<[^>]*>//g')
    day2_condition=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%C&day=1" | sed 's/<[^>]*>//g')
    day3_condition=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%C&day=2" | sed 's/<[^>]*>//g')
    
    # Approach that works with IP-based location (use full URL)
    day1_weather=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%c+%t+%w" | sed 's/<[^>]*>//g')
    day2_weather=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%c+%t+%w&day=1" | sed 's/<[^>]*>//g')
    day3_weather=$(curl -s "wttr.in/$LOC_PARAM?$UNITS_PARAM&format=%c+%t+%w&day=2" | sed 's/<[^>]*>//g')
    
    full_forecast="${today}: ${day1_weather} (${day1_condition})
${tomorrow}: ${day2_weather} (${day2_condition})
${day_after}: ${day3_weather} (${day3_condition})"
    ;;
esac

# Apply privacy settings if enabled
if [ "$PRIVACY_MODE" = "on" ]; then
  weather=$(echo "$weather" | sed -E 's/^[^:]+://; s/^[[:space:]]+//')
  forecast=$(echo "$forecast" | sed -E 's/^[^:]+://; s/^[[:space:]]+//')
  if [ "$FORECAST_TYPE" = "3day" ]; then
    :
  fi
fi

# Random comments :P
comments=(
  "Looks fine. Still not going out :("
  "Feels like the world is rebooting."
  "Probably survivable."
  "Same air, different day."
)
comment=$(shuf -n 1 -e "${comments[@]}")

echo -e "\n${BOLD}${BLUE}=== Weather Update (${TEMP_UNIT}) ===${RESET}\n"

if [ "$PRIVACY_MODE" = "on" ]; then
  echo -e "${BOLD}${CYAN}🌍  Weather:${RESET} $weather"
else
  echo -e "${BOLD}${CYAN}🌍  Weather:${RESET} $forecast"
fi

if [ "$FORECAST_TYPE" == "detailed" ]; then
  echo -e "${BOLD}${PURPLE}📊 Details:${RESET} $details"
  echo -e "${BOLD}${PURPLE}🔍 Condition:${RESET} $condition"
elif [ "$FORECAST_TYPE" == "3day" ]; then
  echo -e "${BOLD}${YELLOW}🗓️  3-Day Forecast:${RESET}"
  echo -e "${BOLD}${YELLOW}   ------------------------------------------${RESET}"
  echo -e "$full_forecast" | while IFS= read -r line; do
    echo -e "   ${BOLD}${YELLOW}$line${RESET}"
  done
  # Add extra echo to separate 3day forecast from comment
  echo
fi
echo
echo -e "${BOLD}${GREEN}💭 Comment:${RESET} $comment\n"

# Send desktop notification only if enabled
if [ "$NOTIFICATIONS" = "on" ]; then
  notify_title="🌤️ Weather Update (${TEMP_UNIT})"
  
  if [ "$PRIVACY_MODE" = "on" ]; then
    notify_body="🌍 Weather: $weather"
  else
    notify_body="🌍 Weather: $forecast"
  fi

  if [ "$FORECAST_TYPE" == "detailed" ]; then
    notify_body+="
📊 Details: $details
🔍 Condition: $condition"
  fi
  
  if [ "$FORECAST_TYPE" == "3day" ]; then
    notify_body+="
🗓️ 3-Day Forecast:
------------------------------------------
$full_forecast
------------------------------------------"
  fi
  
  # Add comment without extra separator for non-3day views
  notify_body+="
💭 $comment"

  notify-send "$notify_title" "$notify_body" --icon=weather-few-clouds
fi