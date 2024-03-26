#!/bin/bash

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
cd "$SCRIPT_DIR" || exit 2

situation=$1
[ "$situation" ] || situation="-d"

# rofi mode
if [ "$situation" == "-d" ]; then
	names=$(cat <./wall_site.txt | xargs -I%% echo %% | rev | cut -d"/" -f3 | rev)
	name=$(echo -e "$names" | rofi -mesg "collection" -dmenu)
	[ "$name" ] && url=$(echo "$name" | xargs -I%% grep %% ./wall_site.txt) || exit
	page_number=$(rofi -mesg "number of page" -dmenu)
	[ "$page_number" ] && dir_name="2_"$name || exit
else
	if [[ "$3" ]]; then
		url=$1
		page_number=$2
		dir_name=$3
	else
		echo -e "\e[31merror\e[0m"
		echo -e ""
		echo -e "help:"
		echo -e "       {url}  {page name}  {dir_name}"
		exit 2
	fi
fi

mkdir -p /home/mostafa/Pictures/Wallpapers
cd "$HOME/Pictures/backgrounds/Wallpapers" || exit 1
python3 ~/.scripts/wallpaper_downloader/wallpaper_downloader.py "$page_number" "$url" "$dir_name"

if [[ "${?}" -ne 0 ]]; then
	notify-send -t 3000 -u critical "error"
	exit 1
else
	notify-send -t 3000 -u low "${page_number} page of ${name} downloaded"
	exit 0
fi
