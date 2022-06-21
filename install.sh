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

printc "  Update apt cache ...\n" "i"
sudo apt update

printc "  Update system package ...\n" "i"
sudo apt upgrade -y

printc "  Installing base packages\n" "i"
sudo apt install ${INIT_PACK[@]} -y

printc "  Installing dependencis\n" "i"
sudo apt install ${DEPS_PACK[@]} -y

SC_FOLDER="$USER_HOME/$PROJECT/scripts"

printc "  Compile and install [pfetch]\n" "i"
cd "$SC_FOLDER/pfetch" && sudo make install

printc "  Install virtualenv\n" "i"
pip install virtualenv


printc "  Check if neovim is installed ...\n" "i"
nvim --version > /dev/null 2>&1
if [ ! $(echo $?) -eq 0 ]; then
	printc "  Installing nvim dependencis\n" "i"
	sudo apt install ${NVIM_COMPILE_DEPS[@]} -y

	# TODO: Correção de erro na instalação do NEOVIM
	#   shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory
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
	# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
	export NVM_DIR="$USER_HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion"  ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	sudo nvm install 14.18.1
else
	printc "  node and npm is installed. \n" "i"
fi

printc "  Installing MongoDB ...\n" "i"
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64  ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt-get update && sudo apt-get install -y mongodb-org
mkdir -p ~/data/db
curl https://raw.githubusercontent.com/mongodb/mongo/master/debian/init.d | sudo tee /etc/init.d/mongodb >/dev/null
sudo chmod +x /etc/init.d/mongodb

# .tmux
bash -c  "$(wget -qO- https://git.io/JCbIh)"


printc "Cleaning files ...\n" "s"

sudo apt autoremove

printc "\nInstalation finished \\o/\n" "s"


