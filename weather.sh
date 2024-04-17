#!/bin/bash

# Variable for colors
RESET="\e[0m"
BOLD="\e[1m"
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
MAGENTA="\e[95m"
CYAN="\e[96m"
WHITE="\e[97m"

# Helper function
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

# verify if user has jq installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}oww, it seems that you don't have jq JSON pawsew installed... pwease do :3${RESET}"
    echo "sewect youw package managew..."
    echo "[1] apt"
    echo "[2] pacman"
    echo "[3] xbps"
    echo "[4] yum"
    echo "[5] dnf"
    echo "[6] brew"
    echo "[7] zypper"
    read -rp "youw choice: " choice
    case $choice in
        1) sudo apt-get update && sudo apt-get install jq awk;;
        2) sudo pacman --sync jq awk;;
        3) sudo xbps-install -S jq awk;;
        4) sudo yum install epel-release && sudo yum install jq awk ;;
        5) sudo dnf install jq awk;;
        6) brew install jq awk;;
        7) sudo zypper install jq awk ;;
        *) echo -e "${RED}oww, you've done a fucky wucky! twy again ow install it manually~${RESET}"; exit 1 ;;
    esac
fi

# API Keys
api_key="1dfeef54f6e423266e0f09920919f297"
ipinfo_key="adc827a697c024"
user_ip=$(curl -s https://ifconfig.me/ip)

# API Requests
location_info=$(curl -s "https://ipinfo.io/$user_ip?token=$ipinfo_key")
lat=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 1)
lon=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 2)
api_url="https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$api_key"
forecast_url="https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$api_key"
weather_data=$(curl -s "$api_url")
forecast_data=$(curl -s "$forecast_url")

# Perform API request and check whether a response has been received
weather_data=$(curl -s "$api_url")
if [ -z "$weather_data" ]; then
    echo -e "${RED}Uh-Oh! Seems wike i'm having twoubwe fetching weathew data, sowwy abouwt thawt! give iwt anothew shot watew, okay? taiw wag${RESET}"
    exit 1
fi

# Check whether the weather data contains a 'name' field (city name)
city=$(echo "$weather_data" | jq -r '.name')
if [ -z "$city" ]; then
    echo -e "${RED}Whoops! Wooks wike i've wost the city nawme! sniff but no wowwies, i'ww find iwt again. Juwst twy again watew!${RESET}"
    exit 1
fi

# Check whether the weather data contains a 'weather' array
weather_desc=$(echo "$weather_data" | jq -r '.weather[].description')
if [ -z "$weather_desc" ]; then
    echo -e "${RED}Oh no! The weathew descwiption seems tuwu have vanished! paw waise but hey, down't fwet, i'ww twy again watew, awwight?${RESET}"
    exit 1
fi

# Check whether the weather data contains a 'wind' field
wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')
if [ -z "$wind_speed" ]; then
    echo -e "${RED}Oopsie! Seems wike the wind iws too stwong awnd bwew away the speed data! eaw fwuttew but no wowwies, i'ww catch iwt again. Twy again watew, okay!${RESET}"
    exit 1
fi


# Weather Description
weather_desc=$(echo "$weather_data" | jq -r '.weather[].description')
wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')
city=$(echo "$weather_data" | jq -r '.name')
if [[ "$city" == "Nur-Sultan" ]]; then
    city='Astana'
fi

# CLI Output
echo ""
echo -e "\t${WHITE}${BOLD}hewwo ${MAGENTA}$USER!${WHITE} i hope u awe doing gweat today!${RESET}"
echo -e "\t${WHITE}${BOLD}hewe is the cuwwent weathew wepowt fow ${GREEN}$city${WHITE} uwu~${RESET}"
echo
echo -e "${GREEN}$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' =)${RESET}"
echo -e "${GREEN}\t$(pad_string "cuwwent" 40) fowecast${RESET}"
echo -e "${GREEN}$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' -)${RESET}"
echo
echo -e "\t$(pad_string "${WHITE}time: $(date +"%H:%M")" 40)${RESET} $(echo "$forecast_data" | jq -r '.list[2].dt_txt' | sed 's#-#/#g;s#...$##;') ----- ${YELLOW}$(echo "$forecast_data" | jq -r '[.list[0].weather[].description, .list[0].main.temp] | join(", ")')°C${RESET}"
echo -e "\t$(pad_string "${WHITE}date: $(date +"%d/%m/%Y")" 40)${RESET} $(echo "$forecast_data" | jq -r '.list[3].dt_txt' | sed 's#-#/#g;s#...$##') ----- ${YELLOW}$(echo "$forecast_data" | jq -r '[.list[1].weather[].description, .list[1].main.temp] | join(", ")')°C${RESET}"
echo -e "\t$(pad_string "${WHITE}weathew: ${YELLOW}${BOLD}\e[5m$(echo "$weather_data" | jq -r '.weather[].description')${RESET}" 40) $(echo "$forecast_data" | jq -r '.list[4].dt_txt' | sed 's#-#/#g;s#...$##') ----- ${YELLOW}$(echo "$forecast_data" | jq -r '[.list[2].weather[].description, .list[2].main.temp] | join(", ")')°C${RESET}"
echo -e "\t$(pad_string "${WHITE}tempewatuwe: ${MAGENTA}$(echo "$weather_data" | jq -r '.main.temp')°C${RESET}" 40) $(echo "$forecast_data" | jq -r '.list[5].dt_txt' | sed 's#-#/#g;s#...$##') ----- ${YELLOW}$(echo "$forecast_data" | jq -r '[.list[3].weather[].description, .list[3].main.temp] | join(", ")')°C${RESET}"
echo -e "\t$(pad_string "${WHITE}wind: ${CYAN}$(echo "$weather_data" | jq -r '.wind.speed')m/s, azimuth: $(echo "$weather_data" | jq -r '.wind.deg')${RESET}" 40) $(echo "$forecast_data" | jq -r '.list[6].dt_txt' | sed 's#-#/#g;s#...$##') ----- ${YELLOW}$(echo "$forecast_data" | jq -r '[.list[4].weather[].description, .list[4].main.temp] | join(", ")')°C${RESET}"
echo -e "\t$(pad_string "${WHITE}cwouds: ${BLUE}$(echo "$weather_data" | jq -r '.clouds.all')%${RESET}" 40) $(echo "$forecast_data" | jq -r '.list[7].dt_txt' | sed 's#-#/#g;s#...$##') ----- ${YELLOW}$(echo "$forecast_data" | jq -r '[.list[5].weather[].description, .list[5].main.temp] | join(", ")')°C${RESET}"
echo
echo -e "${GREEN}$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' -)${RESET}"

# Weather Condition Checks
if [[ "$weather_desc" == "clear sky" ]]; then
    echo -e "\t${YELLOW}seems to be a pwetty cleaw sky today!${RESET}"
elif [[ "$weather_desc" == *"clouds"* ]]; then
    echo -e "\t${BLUE}some cwouds awe pwesent but it's ok :3 i like cwouds!!!!${RESET}"
elif [[ "$weather_desc" == *"rain"* || "$weather_desc" == *"drizzle"* ]]; then
    echo -e "\t${CYAN}looks like it's wainin today, make suwe u bwing an umbwella with u :3${RESET}"
elif [[ "$weather_desc" == *"thunderstorm"* ]]; then
    echo -e "\t${RED}a thundewsowm is coming! pwepawe youwself!${RESET}"
elif [[ "$weather_desc" == *"snow"* ]]; then
    echo -e "\t${WHITE}thewe is going to be snow today! be caweful outside~${RESET}"
elif [[ "$weather_desc" == "fog" || "$weather_desc" == "mist" ]]; then
    echo -e "\t${RED}the fog is coming owo~${RESET}"
elif [[ "$weather_desc" == "smoke" || "$weather_desc" == "haze" ]]; then
    echo -e "\t${RED}somebody is gwilling weally hawd today!! expect some smoke~${RESET}"
fi

# Additional Weather Condition Checks
wind_speed_rounded=$(echo "$wind_speed" | awk '{ print int($1) }')
if [ "$wind_speed_rounded" -gt 8 ]; then
    echo -e "\t${CYAN}wind is stwong, be caweful!${RESET}"
fi    

if [ "$(date +"%d/%m")" == "31/12" ]; then
    echo -e "\t${MAGENTA}${BOLD}happy new yeaw!!! >w<${RESET}"
fi

temperature_rounded=$(echo "$weather_data" | jq -r '.main.temp' | awk '{ print int($1) }')
if [ "$temperature_rounded" -gt 30 ]; then
    echo -e "\t${RED}the weathew is weally hot today, make suwe u dwink enough watew!${RESET}"
elif [ "$temperature_rounded" -lt 15 ]; then
    echo -e "\t${BLUE}the weathew is weally cowd today, make suwe u dwess pwopewwy!${RESET}"
elif [ "$temperature_rounded" -lt -20 ]; then
    echo -e "\t${WHITE}it's fucking fweezing outside!! take cawe and dwess pwopewly!!! TwT${RESET}"
fi

echo -e "${GREEN}$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' =)${RESET}"

#verify if user has jq installed
if ! command -v jq &> /dev/null; then
echo "oww, it seems that you don't have jq JSON pawsew installed... pwease do :3"
echo "sewect youw package managew..."
echo "[1] apt"
echo "[2] pacman"
echo "[3] xbps"
echo "[4] yum"
echo "[5] dnf"
echo "[6] brew"
echo "[7] zypper"
read -rp "youw choice: " choice
case $choice in
    1) sudo apt-get update && sudo apt-get install jq awk;;
    2) sudo pacman --sync jq awk;;
    3) sudo xbps-install -S jq awk;;
    4) sudo yum install epel-release && sudo yum install jq awk ;;
    5) sudo dnf install jq awk;;
    6) brew install jq awk;;
    7) sudo zypper install jq awk ;;
    *) echo "oww, you've done a fucky wucky! twy again ow install it manually~"; exit 1 ;;
    esac
fi

#formatting the output

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

#api requests

api_key="1dfeef54f6e423266e0f09920919f297"
ipinfo_key="adc827a697c024"
user_ip=$(curl -s https://ifconfig.me/ip)

location_info=$(curl -s "https://ipinfo.io/$user_ip?token=$ipinfo_key")
lat=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 1)
lon=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 2)

api_url="https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$api_key"
forecast_url="https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$api_key"

weather_data=$(curl -s "$api_url")
forecast_data=$(curl -s "$forecast_url")

weather_desc=$(echo "$weather_data" | jq -r '.weather[].description')
wind_speed=$(echo "$weather_data" | jq -r '.wind.speed')

city=$(echo "$weather_data" | jq -r '.name')
if [[ "$city" == "Nur-Sultan" ]] ; then
city='Astana';
fi

#cli output

echo ""
echo -e "\t\e[37mhewwo \e[35m$USER!\e[37m i hope u awe doing gweat today!\e[0m"
echo -e "\t\e[37mhewe is the cuwwent weathew wepowt fow \e[32m$city\e[37m uwu~\e[0m"
echo
echo -e "\e[32m$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' =)\e[0m"
echo -e "\e[32m\t$(pad_string "cuwwent" 40) fowecast"
echo -e "\e[32m$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' -)\e[0m"
echo
echo -e "\t$(pad_string "\e[37mtime: $(date +"%H:%M")" 40)\e[0m $(echo "$forecast_data" | jq -r '.list[2].dt_txt' | sed 's#-#/#g;s#...$##;') ----- \e[33m$(echo "$forecast_data" | jq -r '[.list[0].weather[].description, .list[0].main.temp] | join(", ")')°C\e[0m"
echo -e "\t$(pad_string "\e[37mdate: $(date +"%d/%m/%Y")" 40)\e[0m $(echo "$forecast_data" | jq -r '.list[3].dt_txt' | sed 's#-#/#g;s#...$##') ----- \e[33m$(echo "$forecast_data" | jq -r '[.list[1].weather[].description, .list[1].main.temp] | join(", ")')°C\e[0m"
echo -e "\t$(pad_string "weathew: \e[33m\e[5m$(echo "$weather_data" | jq -r '.weather[].description')\e[0m" 40) $(echo "$forecast_data" | jq -r '.list[4].dt_txt' | sed 's#-#/#g;s#...$##') ----- \e[33m$(echo "$forecast_data" | jq -r '[.list[2].weather[].description, .list[2].main.temp] | join(", ")')°C\e[0m"
echo -e "\t$(pad_string "\e[37mtempewatuwe: \e[35m$(echo "$weather_data" | jq -r '.main.temp')°C\e[0m" 40) $(echo "$forecast_data" | jq -r '.list[5].dt_txt' | sed 's#-#/#g;s#...$##') ----- \e[33m$(echo "$forecast_data" | jq -r '[.list[3].weather[].description, .list[3].main.temp] | join(", ")')°C\e[0m"
echo -e "\t$(pad_string "\e[37mwind: \e[37m\e[36m$(echo "$weather_data" | jq -r '.wind.speed')m/s, azimuth: $(echo "$weather_data" | jq -r '.wind.deg')\e[0m" 40) $(echo "$forecast_data" | jq -r '.list[6].dt_txt' | sed 's#-#/#g;s#...$##') ----- \e[33m$(echo "$forecast_data" | jq -r '[.list[4].weather[].description, .list[4].main.temp] | join(", ")')°C\e[0m"
echo -e "\t$(pad_string "\e[37mcwouds: \e[37m\e[34m$(echo "$weather_data" | jq -r '.clouds.all')%\e[0m" 40) $(echo "$forecast_data" | jq -r '.list[7].dt_txt' | sed 's#-#/#g;s#...$##') ----- \e[33m$(echo "$forecast_data" | jq -r '[.list[5].weather[].description, .list[5].main.temp] | join(", ")')°C\e[0m"
echo
echo -e "\e[32m$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' -)\e[0m"
if [[ "$weather_desc" == "clear sky" ]]; then
    echo -e "\t\e[33mseems to be a pwetty cleaw sky today!\e[0m"
elif [[ "$weather_desc" == *"clouds"* ]]; then
    echo -e "\t\e[34msome cwouds awe pwesent but it's ok :3 i like cwouds!!!!\e[0m"
elif [[ "$weather_desc" == *"rain"* || "$weather_desc" == *"drizzle"* ]]; then
    echo -e "\t\e[36mlooks like it's wainin today, make suwe u bwing an umbwella with u :3\\e[0m"
elif [[ "$weather_desc" == *"thunderstorm"* ]]; then
    echo -e "\t\e[31ma thundewsowm is coming! pwepawe youwself!\e[0m"
elif [[ "$weather_desc" == *"snow"* ]]; then
    echo -e "\t\e[37mthewe is going to be snow today! be caweful outside~\e[0m"
elif [[ "$weather_desc" == "fog" || "$weather_desc" == "mist" ]]; then
    echo -e "\t\e[31mthe fog is coming owo~\e[0m"
elif [[ "$weather_desc" == "smoke" || "$weather_desc" == "haze" ]]; then
    echo -e "\t\e[31msomebody is gwilling weally hawd today!! expect some smoke~\e[0m"
fi

wind_speed_rounded=$(echo "$wind_speed" | awk '{ print int($1) }')
if [ "$wind_speed_rounded" -gt 8 ] ; then
    echo -e "\t\e[36mwind is stwong, be caweful!\e[0m"
fi    

if [ "$(date +"%d/%m")" == "31/12" ]; then
    echo -e "\t\e[35m\e[5mhappy new yeaw!!! >w<\e[0m"
fi

temperaure_rounded=$(echo "$weather_data" | jq -r '.main.temp' | awk '{ print int($1) }')
if [ "$temperaure_rounded" -gt 30 ] ; then
    echo -e "\t\e[31mthe weathew is weally hot today, make suwe u dwink enough watew!\e[0m"
elif [ "$temperaure_rounded" -lt 15 ] ; then
    echo -e "\t\e[34mthe weathew is weally cowd today, make suwe u dwess pwopewwy!\e[0m"
elif [ "$temperaure_rounded" -lt -20 ] ; then
    echo -e "\t\e[37mit's fucking fweezing outside!! take cawe and dwess pwopewly!!! TwT\e[0m"
fi

echo -e "\e[32m$(printf '%*s\n' "${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}" '' | tr ' ' =)\e[0m"
