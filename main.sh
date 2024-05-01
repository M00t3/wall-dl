#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
cd "$SCRIPT_DIR" || exit 2

# download path
DOWNLOAD_DIR="$HOME/Pictures/backgrounds/Wallpapers"

flag=$1
[ "$flag" ] || flag="-d"

is_package_installed() {
	which "$1" &>/dev/null
	if [ $? -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

have_notfiy=false
if is_package_installed "notify-send"; then
	have_notfiy=true
fi

# get parameters with rofi or from command line
if [ "$flag" == "-d" ]; then
	names=$(cat <./wall_site.txt | xargs -I%% echo %% | rev | cut -d"/" -f3 | rev)
	name=$(echo -e "$names" | rofi -p "collection" -dmenu)
	[ "$name" ] && url=$(echo "$name" | xargs -I%% grep %% ./wall_site.txt) || exit
	page_number=$(rofi -p "number of page" -dmenu)
	[ "$page_number" ] && dir_name="$name" || exit
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

[[ ! -d "$DOWNLOAD_DIR" ]] && mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit 1

# download wallpapers
python3 "$SCRIPT_DIR"/wallpaper_downloader.py "$page_number" "$url" "$dir_name"
return_code=$?

# if download failed
if [[ $return_code -ne 0 ]]; then
	if $have_notfiy; then
		notify-send -t 3000 -u critical "error"
	else
		echo -e "\e[31merror\e[0m"
	fi
	exit 1
fi

if $have_notfiy; then
	notify-send -t 3000 -u low "${page_number} page of ${name} downloaded"
else
	echo -e "\e[32m${page_number} page of ${name} downloaded\e[0m"
fi

exit 0
