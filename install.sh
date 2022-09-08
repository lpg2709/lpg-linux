#!/bin/bash

PROJECT="lpg-linux"

INIT_PACK=("curl" "wget" "tmux" "net-tools" "python" "htop" "jq" "neovim" "make" "neofetch" "silversearcher-ag")

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

printc "\nStarting installation...\n" "i"
USER_HOME=$(eval echo ~${SUDO_USER})
USER_NAME="${SUDO_USER:-$USER}"
printc "  Current user home: $USER_HOME\n" "l"

if [ ! -d "$USER_HOME" ]; then
	printc "User not found!\n" "e"
	exit 1
fi

printc "  Installing update\n" "i"
pkg upgrade -y

printc "  Installing base packages\n" "i"
pkg install ${INIT_PACK[@]} -y

CF_FOLDER="$USER_HOME/$PROJECT/config-files"
SC_FOLDER="$USER_HOME/$PROJECT/scripts"

printc "  Creating configurations files\n" "i"
# config all
git clone https://gitlab.com/lpg2709/dotfiles "$USER_HOME/dotfiles"
/bin/bash "$USER_HOME/dotfiles/install.sh"
rm -rf "$USER_HOME/dotfiles"

printc "  Setup storageaccess\n" "i"
termux-setup-storage

printc "Cleaning files and prepering for reboot\n" "s"

apt autoremove

printc "\nInstalation finished \\o/\n" "s"

