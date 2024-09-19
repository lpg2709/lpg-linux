#!/bin/bash

PROJECT="lpg-linux"

NVIM_VERSION="stable"
FZF_VERSION="0.55.0"
FZF_ARCH="amd64"

PACKAGES=("curl" "wget" "vim" "make" "build-essential" "tmux" "net-tools" "python3" "htop" "jq" "cmake" "tcpdump" "python3-pip")
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

printc "  Installing packages\n" "i"
sudo apt install ${PACKAGES[@]} -y

printc "  Check if neovim is installed ...\n" "i"
nvim --version > /dev/null 2>&1
if [ ! $(echo $?) -eq 0 ]; then
	printc "  Installing nvim dependencis\n" "i"
	sudo apt install ${NVIM_COMPILE_DEPS[@]} -y
	printc "  Install nvim\n" "i"
	git clone https://github.com/neovim/neovim "$USER_HOME/neovim"
	cd "$USER_HOME/neovim" && git checkout "$NVIM_VERSION" && make CMAKE_BUILD_TYPE=Release && sudo make install
	rm -rf "$USER_HOME/neovim"
else
	printc "  neovim is installed. \n" "i"
fi

if [ ! -d "$USER_HOME/.config/nvim" ]; then
	printc "Install configurations for nvim and tmux\n" "s"
	git clone https://gitlab.com/lpg2709/dotfiles "$USER_HOME/dotfiles"
	cd "$USER_HOME/dotfiles" && ./install.sh --nvim --tmux --vim && rm -rf "$USER_HOME/dotfiles"
fi

if ! command -v fzf; then
	printc "Installing fzf ...\n" "i"
	FZF_FILE="fzf-${FZF_VERSION}-linux_${FZF_ARCH}.tar.gz"
	printc "  Downloading ...\n" "i"
	cd "$USER_HOME" && wget "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/$FZF_FILE"
	printc "  Installing ...\n" "i"
	sudo tar xf "$USER_HOME/$FZF_FILE" -C "/usr/bin/"
	rm -rf "$USER_HOME/$FZF_FILE"
	printc "Done\n" "s"
fi

printc "Creating some alias ...\n" "i"
if ! command -v so; then
	echo "alias so='source ~/.bashrc'" >> $USER_HOME/.bashrc
fi

if ! command -v thunar; then
	echo "alias thunar='explorer.exe'" >> $USER_HOME/.bashrc
fi

if ! command -v cmd; then
	echo "alias cmd='cmd.exe'" >> $USER_HOME/.bashrc
fi

if ! command -v cls; then
	echo "alias cls='clear'" >> $USER_HOME/.bashrc
fi

echo -e 'if command -v fzf; then \n\teval "$(fzf --bash)" \nfi' >> $USER_HOME/.bashrc

printc "Done\n" "s"

printc "Cleaning files ...\n" "s"

sudo apt autoremove

printc "\nInstalation finished \\o/\n" "s"


