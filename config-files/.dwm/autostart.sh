#!/bin/bash

dwm_date() {
	DATA=$(date +"%F %R")
	echo "[  ${DATA} ]"
}

dwm_weather() {
	DATA=$(curl -s wttr.in?format=1 | grep -o "[+\-][0-9].*")
	if [ "$DATA" == "" ]; then
		echo "[ null ]"
	else
		echo "[ ${DATA} ]"
	fi
}
dwm_hdd(){
	free="$(df -h /home | grep /dev | awk '{print $3}')"
	total="$(df -h /home | grep /dev | awk '{print $2}')"
	perc="$(df -h /home | grep /dev | awk '{print $5}')"

	echo "[  $free/$total ($perc) ]"
}

dwm_pkgupdates() {
	upgrds="$(aptitude search '~U' | wc -l)"
	total="$(dpkg -l | grep -c ^i)"

	echo "[  $upgrds/$total ]"
}

dwm_getBatteryPerc() {
	perc=$(cat /sys/class/power_supply/BAT0/capacity)
	isCharging=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "state:               discharging" | wc -l)

	if [ ! $isCharging -eq 1 ]; then
		icon=""
	elif [ $perc -gt 75 ]; then
		icon=""
	elif [ $perc -gt 50 ]; then
		icon=""
	elif [ $perc -gt 25 ]; then
		icon=""
	elif [ $perc -gt 15 ]; then
		icon=""
	elif [ $perc -gt 5 ]; then
		icon=""
	fi
	echo "[ $icon $perc% ]"
}

dwm_resources () {
	# get all the infos first to avoid high resources usage
	free_output=$(free -h | grep Mem)
	df_output=$(df -h $df_check_location | tail -n 1)
	# Used and total memory
	MEMUSED=$(echo $free_output | awk '{print $3}')
	MEMTOT=$(echo $free_output | awk '{print $2}')
	# CPU
	CPU=$(top -bn1 | grep Cpu | awk '{print $2}')%
	if [ "$(ls /sys/class/thermal/ | grep "thermal_zone" | wc -l)" -gt 0 ]; then
		CPU_INDEX="$(cat /sys/class/thermal/thermal_zone*/type | nl -v 0 | grep 'x86_pkg_temp' | awk '{ print $1  }')"
		CPU_TMP_="$(cat /sys/class/thermal/thermal_zone$CPU_INDEX/temp)"
		CPU_TMP="$((CPU_TMP_/1000))"
		echo "[  $MEMUSED/$MEMTOT  $CPU $CPU_TMP°C]"
	else
		echo "[  $MEMUSED/$MEMTOT  $CPU ]"
	fi
}

count_weather=0
count_hdd=0
weather="$(dwm_weather)"
hdd="$(dwm_hdd)"
pkgupdate="$(dwm_pkgupdates)"

while true; do
	if [ "$count_weather" -gt 120 ]; then # 1 h
		weather="$(dwm_weather)"
		pkgupdate="$(dwm_pkgupdates)"
		count_weather=0
	fi

	if [ "$count_hdd" -gt 60 ]; then # 30 min
		hdd="$(dwm_hdd)"
		count_hdd=0
	fi

	count_weather=$((count_weather + 1))
	count_hdd=$((count_hdd + 1))
	xsetroot -name "$(dwm_resources) $hdd $pkgupdate $weather $(dwm_getBatteryPerc) $(dwm_date)"
	sleep 30s
done &

if [ $(xrandr | grep " connected " | awk '{ print$1  }' | grep "HDMI-" | wc -l) -eq 1 ]; then
	xrandr --output HDMI-2 --mode 1920x1080 --output eDP-1 --mode 1920x1080 --right-of HDMI-2
elif [ $(xrandr | grep " connected " | awk '{ print$1  }' | grep "DP-" | wc -l) -gt 1 ]; then
	xrandr --output DP-1 --mode 1366x768 --output eDP-1 --mode 1920x1080 --right-of DP-1
else
	xrandr --output eDP-1 --mode 1920x1080
fi

setxkbmap -model abnt2 -layout br -variant abnt2
fehbg
teams
exec dwm
