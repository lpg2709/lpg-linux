#!/bin/bash

set -e
PROJECT="lpg-linux"

# Import other functions
source "./commons/printc.sh"
source "./commons/checks.sh"

check_root

USER_HOME=$(eval echo ~${SUDO_USER})
USER_NAME="${SUDO_USER:-$USER}"

DEPS_PACK=("vim" "make" "build-essential" "libx11-dev" "libxft-dev")
POST_PACK=("tmux" "net-tools" "python3" "htop" "jq" "firefox-esr" "cmake" "tcpdump")

PROGRAMS_FOLDER="$USER_HOME/$PROJECT/programs"
SUCKLESS_FOLDER="$USER_HOME/$PROJECT/suckless"

printc "\nStarting installation...\n" "i"

printc "  Current user home: $USER_HOME\n" "l"

if [ ! -d "$USER_HOME" ]; then
	printc "User not found!\n" "e"
	exit 1
fi

printc "  Update the system\n" "i"
sudo apt upgrade -y

printc "  Installing base packages and dependencis\n" "i"
sudo apt install ${DEPS_PACK[@]} -y

printc "  Compile and install [st]\n" "i"
cd "$SUCKLESS_FOLDER/st" && sudo make clean install

printc "  Compile and install [pfetch]\n" "i"
cd "$PROGRAMS_FOLDER/pfetch" && sudo make install

printc "  Returning to project folder\n" "i"
cd "$USER_HOME/$PROJECT"

printc "  Installing programs\n" "i"
sudo apt install ${POST_PACK[@]} -y

printc "Cleaning files\n" "s"
sudo apt autoremove


