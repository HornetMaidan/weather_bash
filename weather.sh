#!/bin/bash

#verify if user has jq installed
if ! command -v jq &> /dev/null; then
echo "oww, it seems that you don't have jq JSON pawsew installed... pwease do :3"
echo "apt: sudo apt-get install jq"
echo "pacman: sudo pacman -S jq"
echo "xbps: sudo xbps-install -S jq"
    exit 1
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
weather_data=$(curl -s $api_url)
#echo $weather_data
weather_desc=$(echo $weather_data | jq -r '.weather[].description')

city=$(echo $weather_data | jq -r '.name')
if [[ "$city" == "Nur-Sultan" ]] ; then
city='Astana';
fi

echo "hewwo $USER! i hope u awe doing gweat today!"
echo "hewe is the cuwwent weathew wepowt fow $city uwu~"
echo "--------------------------------------------"
echo "time: $(date +"%H:%M")"
echo "date: $(date +"%d/%m/%Y")"
echo "weathew: $(echo "$weather_data" | jq -r '.weather[].description')"
echo "tempewature: $(echo "$weather_data" | jq -r '.main.temp')°C"
echo "wind: $(echo "$weather_data" | jq -r '.wind.speed')m/s, azimuth: $(echo "$weather_data" | jq -r '.wind.deg')"
echo "cwouds: $(echo "$weather_data" | jq -r '.clouds.all')%"
echo "--------------------------------------------"
if [[ "$weather_desc" == "clear sky" ]]; then
    echo "seems to be a pretty clear sky today!"
elif [[ "$weather_desc" == *"clouds"* ]]; then
    echo "some cwouds awe pwesent but it's ok :3 i like cwouds!!!!"
elif [[ "$weather_desc" == *"rain"* ]]; then
    echo "looks like it's wainin today, make suwe u bring an umbwella with u :3"
elif [[ "$weather_desc" == *"thunderstorm"* ]]; then
    echo "a thundewsowm is coming! pwepawe youwself!"
elif [[ "$weather_desc" == *"snow"* ]]; then
    echo "thewe is going to be snow today! be caweful outside~"
elif [[ "$weather_desc" == "fog" || "$weather_desc" == "mist" ]]; then
    echo "the fog is coming uwu~"
fi
