#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # #
# Written by: https://github.com/HornetMaidan/    #
# https://github.com/HornetMaidan/                #
#                                                 #
# Refactored by:                                  #
# https://github.com/0n1cOn3                      #
# # # # # # # # # # # # # # # # # # # # # # # # # #

# Variables for weather.sh
api_key="1dfeef54f6e423266e0f09920919f297"
ipinfo_key="adc827a697c024"

user_ip=$(curl -s https://ifconfig.me/ip)
location_info=$(curl -s "https://ipinfo.io/$user_ip?token=$ipinfo_key")

api_url="https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$api_key"
forecast_url="https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$api_key"

lat=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 1)
lon=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 2)

weather_data=$(curl -s "$api_url")
forecast_data=$(curl -s "$forecast_url")

weather_desc=$(echo "$weather_data" | jq -r '.weather[].description')
wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')

#                                         Main application                                        #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Check if the user has jq installed
if ! command -v jq &> /dev/null; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "You need root privileges to install jq."
        exit 1
    fi
    echo "It seems that jq is not installed. Please select your package manager:"
    echo "[1] apt"
    echo "[2] pacman"
    echo "[3] xbps"
    echo "[4] yum"
    echo "[5] dnf"
    echo "[6] brew"
    echo "[7] zypper"
    read -rp "Your choice: " choice
    case $choice in
        1) sudo apt-get update && sudo apt-get install jq awk;;
        2) sudo pacman --sync jq awk;;
        3) sudo xbps-install -S jq awk;;
        4) sudo yum install epel-release && sudo yum install jq awk ;;
        5) sudo dnf install jq awk;;
        6) brew install jq awk;;
        7) sudo zypper install jq awk ;;
        *) echo "Invalid input! Please try again or install jq manually."; exit 1 ;;
    esac
fi

# Functions for text formatting
strip_ansi_escape_codes() {
    echo -ne "$1" | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"
}
pad_string() {
    local string="$1"
    local length="$2"
    local stripped=""
    stripped=$(strip_ansi_escape_codes "$string")
    local spaces=$((length - ${#stripped}))
    printf "%s%*s" "$string" "$spaces" ""
}

# Adjusting city name
city=$(echo "$weather_data" | jq -r '.name')
if [[ "$city" == "Nur-Sultan" ]]; then
    city='Astana';
fi

# CLI output
echo ""
echo -e "\tHello $USER! I hope you are doing well!"
echo -e "\tHere is the current weather report for $city."
echo
echo -e "$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' =)"
echo -e "\t$(pad_string "Current" 40) Forecast"
echo -e "$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' -)"
echo
echo -e "\t$(pad_string "Time: $(date +"%H:%M")" 40) $(echo "$forecast_data" | jq -r '.list[2].dt_txt' | sed 's#-#/#g;s#...$##;') ----- $(echo "$forecast_data" | jq -r '[.list[0].weather[].description, .list[0].main.temp] | join(", ")')°C"
echo -e "\t$(pad_string "Date: $(date +"%d/%m/%Y")" 40) $(echo "$forecast_data" | jq -r '.list[3].dt_txt' | sed 's#-#/#g;s#...$##') ----- $(echo "$forecast_data" | jq -r '[.list[1].weather[].description, .list[1].main.temp] | join(", ")')°C"
echo -e "\t$(pad_string "Weather: $(echo "$weather_data" | jq -r '.weather[].description')" 40) $(echo "$forecast_data" | jq -r '.list[4].dt_txt' | sed 's#-#/#g;s#...$##') ----- $(echo "$forecast_data" | jq -r '[.list[2].weather[].description, .list[2].main.temp] | join(", ")')°C"
echo -e "\t$(pad_string "Temperature: $(echo "$weather_data" | jq -r '.main.temp')°C" 40) $(echo "$forecast_data" | jq -r '.list[5].dt_txt' | sed 's#-#/#g;s#...$##') ----- $(echo "$forecast_data" | jq -r '[.list[3].weather[].description, .list[3].main.temp] | join(", ")')°C"
echo -e "\t$(pad_string "Wind: $(echo "$weather_data" | jq -r '.wind.speed')m/s, Azimuth: $(echo "$weather_data" | jq -r '.wind.deg')" 40) $(echo "$forecast_data" | jq -r '.list[6].dt_txt' | sed 's#-#/#g;s#...$##') ----- $(echo "$forecast_data" | jq -r '[.list[4].weather[].description, .list[4].main.temp] | join(", ")')°C"
echo -e "\t$(pad_string "Clouds: $(echo "$weather_data" | jq -r '.clouds.all')%" 40) $(echo "$forecast_data" | jq -r '.list[7].dt_txt' | sed 's#-#/#g;s#...$##') ----- $(echo "$forecast_data" | jq -r '[.list[5].weather[].description, .list[5].main.temp] | join(", ")')°C"
echo
echo -e "$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' -)"
# Weather description
case "$weather_desc" in
    "clear sky")
        echo -e "\tSeems to be a pretty clear sky today!"
        ;;
    *"clouds"*)
        echo -e "\tSome clouds are present but it's okay. I like clouds!"
        ;;
    *"rain"* | *"drizzle"*)
        echo -e "\tLooks like it's raining today. Make sure you bring an umbrella with you."
        ;;
    *"thunderstorm"*)
        echo -e "\tA thunderstorm is coming! Prepare yourself!"
        ;;
    *"snow"*)
        echo -e "\tThere is going to be snow today! Be careful outside."
        ;;
    "fog" | "mist")
        echo -e "\tThe fog is coming."
        ;;
    "smoke" | "haze")
        echo -e "\tSomebody is grilling really hard today! Expect some smoke."
        ;;
esac

# Check for strong wind
wind_speed_rounded=$(echo "$wind_speed" | awk '{ print int($1) }')
if [ "$wind_speed_rounded" -gt 8 ]; then
    echo -e "\tWind is strong. Be careful!"
fi    

# Special message for New Year's Eve
if [ "$(date +"%d/%m")" == "31/12" ]; then
    echo -e "\tHappy New Year!!!"
fi

# Check for extreme temperatures
temperature_rounded=$(echo "$weather_data" | jq -r '.main.temp' | awk '{ print int($1) }')
if [ "$temperature_rounded" -gt 30 ]; then
    echo -e "\tThe weather is really hot today. Make sure you drink enough water!"
elif [ "$temperature_rounded" -lt 15 ]; then
    echo -e "\tThe weather is really cold today. Make sure you dress properly!"
elif [ "$temperature_rounded" -lt -20 ]; then
    echo -e "\tIt's freezing outside!! Take care and dress properly!"
fi

echo -e "$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' =)"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                              End                                                #
