#!/bin/bash

#to-do:
#colorcode the output --- DONE
#automatic detection of package manager to install jq(at least apt/pacman/xbps/etc..) --- DONE(semi-auto preferred)
#uwufy everything --- DONE uwu~

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
    1) sudo apt-get update && sudo apt-get install jq ;;
    2) sudo pacman --sync jq ;;
    3) sudo xbps-install -S jq ;;
    4) sudo yum install epel-release && sudo yum install jq ;;
    5) sudo dnf install jq ;;
    6) brew install jq ;;
    7) sudo zypper install jq ;;
    *) echo "oww, you've done a fucky wucky! twy again ow install it manually~"; exit 1 ;;
    esac
fi

api_key="a6c3cfde026d31b995612c6f169203a7"
ipinfo_key="bd1acc5f04e870"
user_ip=$(curl -s https://ifconfig.me/ip)
#echo $user_ip

location_info=$(curl -s https://ipinfo.io/$user_ip?token=$ipinfo_key)
#echo $location_info
lat=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 1)
lon=$(echo "$location_info" | jq -r '.loc' | cut -d ',' -f 2)

#echo $lat $lon


api_url="https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$api_key"
#echo $api_url
weather_data=$(curl -s "$api_url")
#echo $weather_data
weather_desc=$(echo "$weather_data" | jq -r '.weather[].description')

city=$(echo "$weather_data" | jq -r '.name')
if [[ "$city" == "Nur-Sultan" ]] ; then
city='Astana';
fi
echo ""
echo -e "\e[37mhewwo \e[35m$USER!\e[37m i hope u awe doing gweat today!\e[0m"
echo -e "\e[37mhewe is the cuwwent weathew wepowt fow \e[32m$city\e[37m uwu~\e[0m"
echo -e "\e[32m--------------------------------------------\e[0m"
echo -e "\e[37mtime: $(date +"%H:%M")\e[37m"
echo -e "date: $(date +"%d/%m/%Y")"
echo -e "weathew: \e[33m\e[5m$(echo "$weather_data" | jq -r '.weather[].description')\e[0m"
echo -e "\e[37mtempewature: \e[37m\e[35m$(echo "$weather_data" | jq -r '.main.temp')°C\e[0m"
echo -e "\e[37mwind: \e[37m\e[36m$(echo "$weather_data" | jq -r '.wind.speed')m/s, azimuth: $(echo "$weather_data" | jq -r '.wind.deg')\e[0m"
echo -e "\e[37mcwouds: \e[37m\e[34m$(echo "$weather_data" | jq -r '.clouds.all')%\e[0m"
echo -e "\e[32m--------------------------------------------\e[0m"
if [[ "$weather_desc" == "clear sky" ]]; then
    echo -e "\e[33mseems to be a pwetty cleaw sky today!\e[0m"
elif [[ "$weather_desc" == *"clouds"* ]]; then
    echo -e "\e[34msome cwouds awe pwesent but it's ok :3 i like cwouds!!!!\e[0m"
elif [[ "$weather_desc" == *"rain"* ]]; then
    echo -e "\e[36mlooks like it's wainin today, make suwe u bwing an umbwella with u :3\\e[0m"
elif [[ "$weather_desc" == *"thunderstorm"* ]]; then
    echo -e "\e[31ma thundewsowm is coming! pwepawe youwself!\e[0m"
elif [[ "$weather_desc" == *"snow"* ]]; then
    echo -e "\e[37mthewe is going to be snow today! be caweful outside~\e[0m"
elif [[ "$weather_desc" == "fog" || "$weather_desc" == "mist" ]]; then
    echo -e "\e[31mthe fog is coming uwu~\e[0m"
fi