#!/bin/bash

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
ipinfo_key="598e73a582179f"
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
