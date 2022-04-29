#!/bin/bash

DWM="dwm-6.2"
DMENU="dmenu-5.0"
ST="st-0.8.4"
PROJECT="lpg-linux"

INIT_PACK=("git" "curl" "wget")
DEPS_PACK=("vim" "make" "base-devel" "libX11-devel" "libXft-devel" "libXinerama-devel" "font-awesome" "feh" "xorg" "xdg-user-dirs")
POST_PACK=("tmux" "net-tools""htop" "jq" "cmake" "tcpdump" "firefox-esr" "Thunar" "baobab" "gnome-disk-utility")

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
sudo xbps-install -Sy ${INIT_PACK[@]}

printc "  Installing dependencis\n" "i"
sudo xbps-install -Sy ${DEPS_PACK[@]}

S_FOLDER="$USER_HOME/$PROJECT/suckless"
CF_FOLDER="$USER_HOME/$PROJECT/config-files"
SC_FOLDER="$USER_HOME/$PROJECT/scripts"
PATCHS_FOLDER="$S_FOLDER/patchs"

printc "  Creating some folders\n" "i"
xdg-user-dirs-update

printc "  Compile and install [dwm-6.2]\n" "i"
cd "$S_FOLDER/$DWM" && sudo make clean install
printc "  Compile and install [st-0.8.4]\n" "i"
cd "$S_FOLDER/$ST" && sudo make clean install
printc "  Compile and install [dmenu-5.0]\n" "i"
cd "$S_FOLDER/$DMENU" && sudo make clean install

printc "  Compile and install [pfetch]\n" "i"
cd "$SC_FOLDER/pfetch" && sudo make install

printc "  Creating configurations files\n" "i"
# .dwm autostart
cp -r "$CF_FOLDER/.dwm" "$USER_HOME/"
sudo chown  "$USER_NAME:$USER_NAME" "$USER_HOME/.dwm/autostart.sh"
# .tmux
bash -c  "$(wget -qO- https://git.io/JCbIh)"
sudo chown  "$USER_NAME:$USER_NAME" "$USER_HOME/.tmux.conf"
# .vimrc
bash -c  "$(wget -qO- https://git.io/JCbTi)"
sudo chown  "$USER_NAME:$USER_NAME" "$USER_HOME/.vimrc"

printc "  Creating dwm.desktop files\n" "i"
# dwm entry
mkdir "/usr/share/xsessions"
sudo cp "$CF_FOLDER/dwm.desktop" "/usr/share/xsessions/"

printc "  Creating some scripts\n" "i"
cp "$SC_FOLDER/fehbg" "/bin/fehbg"
cp "$SC_FOLDER/pmenu" "/bin/pmenu"
cp "$SC_FOLDER/helpdwm" "/bin/helpdwm"
cp -r "$SC_FOLDER/dwm-help" "/bin/dwm-help"

printc "  Copy wallpapers\n" "i"
sudo mkdir -p "/usr/share/wallpapers/$PROJECT"
sudo cp -a "$USER_HOME/$PROJECT/img/wallpapers/." "/usr/share/wallpapers/$PROJECT"

printc "  Copy Gruvbox theme\n" "i"
sudo cp -rf "$USER_HOME/$PROJECT/theme/gruvbox-material-gtk/themes/." "/usr/share/themes"
sudo cp -rf "$USER_HOME/$PROJECT/theme/gruvbox-material-gtk/icons/." "/usr/share/icons"
sudo gtk-update-icon-cache "/usr/share/icons/Gruvbox-Material-Dark"

printc "  Setup Gruvbox theme\n" "i"
mkdir -p "$USER_HOME/.config/gtk-3.0"
cp "$CF_FOLDER/gtk-3.0/settings.ini" "$USER_HOME/.config/gtk-3.0/"
sudo chown  "$USER_NAME:$USER_NAME" "$USER_HOME/.config/gtk-3.0/settings.ini"

printc "  Installing programs\n" "i"
sudo xbps-install -Sy ${POST_PACK[@]} -y

# printc "Cleaning files and prepering for reboot\n" "s"

# sudo apt autoremove

printc "\nInstalation finished \\o/\n" "s"

