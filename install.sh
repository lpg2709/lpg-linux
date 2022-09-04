#!/bin/bash

DWM="dwm-6.2"
DMENU="dmenu-5.0"
ST="st-0.8.4"
PROJECT="lpg-linux"

INIT_PACK=("git" "curl" "wget" "vim" "make" "cmake" "base-devel" "libX11-devel" "libXft-devel" "libXinerama-devel" "font-awesome" "feh" "xorg" "xdg-user-dirs" "lightdm" "lightdm-gtk3-greeter" "pulseaudio")
POST_PACK=("tmux" "net-tools" "htop" "jq" "tcpdump" "firefox-esr" "Thunar" "baobab" "gnome-disk-utility" "pavucontrol")

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

printc "  Changing Mirrors to https://repo-us.voidlinux.org/ in USA: Kansas City\n" "i"
mkdir -p /etc/xbps.d
echo "repository=https://repo-us.voidlinux.org/current/" > /etc/xbps.d/00-repository-main.conf
xbps-install -S

printc "   LOG: Check the repositorys\n" "i"
xbps-query -L

printc "  Update the system\n" "i"
xbps-install -Suy

printc "  Installing base packages and dependencis\n" "i"
sudo xbps-install -Sy ${INIT_PACK[@]}

S_FOLDER="$USER_HOME/$PROJECT/suckless"
CF_FOLDER="$USER_HOME/$PROJECT/config-files"
SC_FOLDER="$USER_HOME/$PROJECT/scripts"

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

printc "  Check if neovim is installed ...\n" "i"
nvim --version > /dev/null 2>&1
if [ ! $(echo $?) -eq 0 ]; then
	printc "  Install nvim\n" "i"
	git clone https://github.com/neovim/neovim "$USER_HOME/Downloads/neovim"
	cd "$USER_HOME/Downloads/neovim" && git checkout stable && make CMAKE_BUILD_TYPE=Release && sudo make install
	sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/Downloads"
	rm -rf "$USER_HOME/Downloads/neovim"
else
	printc "  neovim is installed. \n" "i"
fi

printc "  Creating configurations files\n" "i"
# .dwm autostart
cp -r "$CF_FOLDER/.dwm" "$USER_HOME/"
sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.dwm"

# config all
git clone https://gitlab.com/lpg2709/dotfiles
cd dotfiles/
sh ./install.sh

printc "  Creating dwm.desktop files\n" "i"
mkdir -p /etc/X11/xorg.conf.d/
sudo cp "$CF_FOLDER/30-keyboard.conf" "/etc/X11/xorg.conf.d/"
# dwm entry
mkdir "/usr/share/xsessions"
sudo cp "$CF_FOLDER/dwm.desktop" "/usr/share/xsessions/"

printc "  Setup lightdm to start on boot\n" "i"
ln -s /etc/sv/dbus /var/service
ln -s /etc/sv/lightdm /var/service
# theme config
sed -i 's/#theme-name=/theme-name = Gruvbox-Material-Dark/' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#icon-theme-name=/icon-theme-name = Gruvbox-Material-Dark/' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#background=/background = /usr/share/wallpapers/lpg-linux/houses.jpg' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf


printc "  Fixing .Xauthority\n" "i"
touch ~/.Xauthority
xauth add ${HOST}:0 . $(xxd -l 16 -p /dev/urandom)

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
sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config/gtk-3.0/settings.ini"

printc "  Installing programs\n" "i"
sudo xbps-install -Sy ${POST_PACK[@]} -y

# printc "Cleaning files and prepering for reboot\n" "s"

# sudo apt autoremove

printc "\nInstalation finished \\o/\n" "s"

