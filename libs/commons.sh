#!/bin/bash

PROJECT="lpgDebian"
C_FOLDER="$HOME/$PROJECT"

# --- FUNCTIONS ---
# Print pretty color output
#  $1: The message to be printed with the color level
#  $2: The message level
#	s = success | w = warning | e = error | i = information | l = log
function printc(){
	CLEAR_COLOR="\033[0m"
	l=$2
	msg=$1
	if [ "$l" = "s" ];then # success
		PRIMARY_COLOR="\033[36;01m"
	fi
	if [ "$l" = "w" ];then # warning
		PRIMARY_COLOR="\033[33;01m"
	fi
	if [ "$l" = "e" ];then # error
		PRIMARY_COLOR="\033[31;01m"
	fi
	if [ "$l" = "i" ];then # info
		PRIMARY_COLOR="\033[34;01m"
	fi
	if [ "$l" = "l" ];then # log
		PRIMARY_COLOR="\033[0;01m"
	fi
	if [ "$l" = "d" ];then # default log
		PRIMARY_COLOR="\033[0m"
	fi

	printf "$PRIMARY_COLOR$msg$CLEAR_COLOR"
}

function reboot_(){
	printc "Rebooting in 3 ...\n" "i"
	sleep 1s
	printc "Rebooting in 2 ...\n" "i"
	sleep 1s
	printc "Rebooting in 1 ...\n" "i"
	sleep 1s
	printc "Rebooting ...\n" "i"
	sleep 1s

	if [ -z "$1" ]; then
		reboot
	else
		sudo reboot
	fi
}

function check_execution(){
	if [ ! "$?" -eq "0" ];then
		printc "Execution error!\n" "e"
		if [ "$1" = "exit" ];then
			printc "Exiting ...\n" "l"
			exit 1
		fi
	else
		printc " ... OK\n" "l"
	fi
}

function check_root(){
	# Check if is root user
	if [[ ! "$(id -u)" -eq "0" ]];then
		printc "\nError: Root user is required!\n\n" "e"
		exit 1
	fi
}
