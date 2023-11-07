#!/bin/bash

dwm_date(){
	DATA=$(date +"%F %R")
	echo "[  ${DATA} ]"
}

dwm_hdd(){
	free="$(df -h /home | grep /dev | awk '{print $3}')"
	total="$(df -h /home | grep /dev | awk '{print $2}')"
	perc="$(df -h /home | grep /dev | awk '{print $5}')"

	echo "[  $free/$total ($perc) ]"
}

dwm_pkgupdates() {
	upgrds="$(aptitude search '~U' | wc -l)"
	total="$(xbps-query -l | wc -l)"

	echo "[  $upgrds/$total ]"
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

count_1h=0
count_hdd=0
hdd="$(dwm_hdd)"
pkgupdate="$(dwm_pkgupdates)"

while true; do
	# to diferent time the count is [sleep_time * x = amount_of_time_in_minutes]
	if [ "$count_1h" -gt 1800 ]; then # 1 h
		pkgupdate="$(dwm_pkgupdates)"
		count_1h=0
	fi

	if [ "$count_hdd" -gt 900 ]; then # 30 min
		hdd="$(dwm_hdd)"
		count_hdd=0
	fi

	count_1h=$((count_1h + 1))
	count_hdd=$((count_hdd + 1))
	xsetroot -name "$(dwm_resources) $hdd $pkgupdate $(dwm_date)"
	sleep 2s
done &

fehbg
exec dwm
