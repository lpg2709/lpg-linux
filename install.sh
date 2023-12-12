#!/bin/bash
DWM="dwm-6.3"
DMENU="dmenu-5.0"
ST="st-0.8.4"
PROJECT="lpg-linux"

INIT_PACK=("git" "curl" "wget")
DEPS_PACK=("vim" "make" "build-essential" "tmux" "net-tools" "python3" "htop" "jq" "cmake" "tcpdump" "python3-pip")
NVIM_COMPILE_DEPS=("ninja-build" "gettext" "libtool" "libtool-bin" "autoconf" "automake" "g++" "pkg-config" "unzip" "doxygen" "ripgrep")

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

# check_root

printc "\nStarting installation...\n" "i"
USER_HOME=$(eval echo ~${SUDO_USER})
USER_NAME="${SUDO_USER:-$USER}"
printc "  Current user home: $USER_HOME\n" "l"

if [ ! -d "$USER_HOME" ]; then
	printc "User not found!\n" "e"
	exit 1
fi

printc "  Update system package ...\n" "i"
sudo apt update && sudo apt upgrade -y

printc "  Installing base packages\n" "i"
sudo apt install ${INIT_PACK[@]} -y

printc "  Installing dependencis\n" "i"
sudo apt install ${DEPS_PACK[@]} -y

printc "  Check if neovim is installed ...\n" "i"
nvim --version > /dev/null 2>&1
if [ ! $(echo $?) -eq 0 ]; then
	printc "  Installing nvim dependencis\n" "i"
	sudo apt install ${NVIM_COMPILE_DEPS[@]} -y
	printc "  Install nvim\n" "i"
	git clone https://github.com/neovim/neovim "$USER_HOME/Downloads/neovim"
	cd "$USER_HOME/Downloads/neovim" && git checkout stable && make CMAKE_BUILD_TYPE=Release && sudo make install
	rm -rf "$USER_HOME/Downloads/neovim"
else
	printc "  neovim is installed. \n" "i"
fi

printc "  Check if node and npm is installed ...\n" "i"
node --version > /dev/null 2>&1
if [ ! $(echo $?) -eq 0 ]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
	export NVIM_DIR="$USER_HOME/.nvm"
	echo "export NVM_DIR=$NVIM_DIR" >> $USER_HOME/.bashrc
	echo "[ -s \"$NVM_DIR/nvm.sh\"  ] && \\. \"$NVM_DIR/nvm.sh\"  # This loads nvm" >> $USER_HOME/.bashrc
	echo "[ -s \"$NVM_DIR/bash_completion\"  ] && \\. \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >> $USER_HOME/.bashrc
	nvm install 14.18.1
else
	printc "  node and npm is installed. \n" "i"
fi

if [ ! -d "$USER_HOME/.config/nvim" ]; then
	printc "Install configurations for nvim and tmux\n" "s"
	git clone https://gitlab.com/lpg2709/dotfiles.git "/tmp/dotfiles"
	/tmp/dotfiles/install.sh --nvim --tmux --vim
	rm -rf "/tmp/dotfiles"
fi

printc "Cleaning files ...\n" "s"

sudo apt autoremove

printc "\nInstalation finished \\o/\n" "s"


