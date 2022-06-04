#!/bin/bash

DWM="dwm-6.3"
DMENU="dmenu-5.0"
ST="st-0.8.4"
PROJECT="lpg-linux"

INIT_PACK=("git" "curl" "wget")
DEPS_PACK=("vim" "make" "build-essential" "tmux" "net-tools" "python3" "htop" "jq" "cmake" "tcpdump" "python3-pip")
NVIM_COMPILE_DEPS=("ninja-build" "gettext" "libtool" "libtool-bin" "autoconf" "automake" "g++" "pkg-config" "unzip" "doxygen")

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

function check_root(){
	# Check if is root user
	if [[ ! "$(id -u)" -eq "0" ]];then
		printc "\nError: Root user is required!\n\n" "e"
		exit 1
	fi
}

check_root

printc "\nStarting installation...\n" "i"
USER_HOME=$(eval echo ~${SUDO_USER})
USER_NAME="${SUDO_USER:-$USER}"
printc "  Current user home: $USER_HOME\n" "l"

if [ ! -d "$USER_HOME" ]; then
	printc "User not found!\n" "e"
	exit 1
fi

printc "  Installing base packages\n" "i"
apt install ${INIT_PACK[@]} -y

printc "  Installing dependencis\n" "i"
sudo apt install ${DEPS_PACK[@]} -y

SC_FOLDER="$USER_HOME/$PROJECT/scripts"

printc "  Compile and install [pfetch]\n" "i"
cd "$SC_FOLDER/pfetch" && sudo make install

printc "  Install virtualenv\n" "i"
pip install virtualenv

printc "  Install nvim" "i"
git clone https://github.com/neovim/neovim "$USER_HOME/Downloads/neovim"
cd "$USER_HOME/Downloads/neovim" && git git checkout stable && make CMAKE_BUILD_TYPE=Release && sudo make install
rm -rf "$USER_HOME/Downloads/neovim"

# .tmux
bash -c  "$(wget -qO- https://git.io/JCbIh)"
sudo chown  "$USER_NAME:$USER_NAME" "$USER_HOME/.tmux.conf"
# .vimrc
bash -c  "$(wget -qO- https://git.io/JCbTi)"
sudo chown  "$USER_NAME:$USER_NAME" "$USER_HOME/.vimrc"


printc "Cleaning files ...\n" "s"

sudo apt autoremove

printc "\nInstalation finished \\o/\n" "s"


