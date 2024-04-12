#!/bin/bash

set -e # Exit if some command return not 0

DWM="dwm-6.4"
DMENU="dmenu-5.0"
ST="st-0.8.4"
PROJECT="lpg-linux"

MIRROR_URL="https://repo-fastly.voidlinux.org/current"
INIT_PACK=("git" "curl" "wget" "vim" "neovim" "make" "cmake" "base-devel" "libX11-devel" "libXft-devel" "libXinerama-devel" "feh" "xorg" "xdg-user-dirs" "lightdm" "lightdm-gtk3-greeter" "pulseaudio")
POST_PACK=("tmux" "net-tools" "htop" "jq" "tcpdump" "firefox-esr" "gvfs" "Thunar" "thunar-archive-plugin" "thunar-volman" "thunar-media-tags-plugin" "tumbler" "baobab" "gnome-disk-utility" "pavucontrol" "xclip" "xarchiver")

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

printc "  Checking mirror\n" "i"
if [ ! -d "/etc/xbps.d" ]; then
	printc "    Nothing found. Changing Mirrors to $MIRROR_URL ..." "i"
	mkdir -p /etc/xbps.d
	echo "repository=$MIRROR_URL" > /etc/xbps.d/00-repository-main.conf
	echo "repository=$MIRROR_URL" > /etc/xbps.d/10-repository-nonfree.conf
	xbps-install -S
	xbps-query -L
	printc "  DONE\n" "i"
else
	mr_ch=0
	if [ -f "/etc/xbps.d/00-repository-main.conf" ]; then
		if [ $(cat "/etc/xbps.d/00-repository-main.conf" | grep $MIRROR_URL | wc -l) -lt 1 ]; then
			echo "repository=$MIRROR_URL" > /etc/xbps.d/00-repository-main.conf
			mr_ch=1
		fi
	else
		echo "repository=$MIRROR_URL" > /etc/xbps.d/00-repository-main.conf
		mr_ch=1
	fi

	if [ -f "/etc/xbps.d/10-repository-nonfree.conf" ]; then
		if [ $(cat "/etc/xbps.d/10-repository-nonfree.conf" | grep $MIRROR_URL | wc -l) -lt 1 ]; then
			echo "repository=$MIRROR_URL" > /etc/xbps.d/10-repository-nonfree.conf
			mr_ch=1
		fi
	else
		echo "repository=$MIRROR_URL" > /etc/xbps.d/10-repository-nonfree.conf
		mr_ch=1
	fi
	if [ $mr_ch -eq 1 ];then
		printc "    Changing Mirrors to $MIRROR_URL.\n" "i"
		xbps-install -S
		printc "   Check the repositorys\n" "i"
		xbps-query -L
	fi
fi

printc "  Update the system\n" "i"
xbps-install -Suy

printc "  Installing base packages and dependencis\n" "i"
sudo xbps-install -Sy ${INIT_PACK[@]}

S_FOLDER="$USER_HOME/$PROJECT/suckless"
CF_FOLDER="$USER_HOME/$PROJECT/configs"
SC_FOLDER="$USER_HOME/$PROJECT/scripts"

printc "  Creating some folders for '${SUDO_USER}'\n" "i"
runuser -l ${SUDO_USER} -c xdg-user-dirs-update
sudo xdg-user-dirs-update

if [ ! -d "$USER_HOME/.config" ];then
	printc "  Creating .config for current user\n" "i"
	sudo mkdir "$USER_HOME/.config"
	sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config"
fi

if [ ! -d "/root/.config" ];then
	printc "  Creating .config for root\n" "i"
	sudo mkdir "/root/.config"
fi

printc "  Compile and install [$DWM]\n" "i"
cd "$S_FOLDER/$DWM" && sudo make clean install
printc "  Compile and install [$ST]\n" "i"
cd "$S_FOLDER/$ST" && sudo make clean install
printc "  Compile and install [$DMENU]\n" "i"
cd "$S_FOLDER/$DMENU" && sudo make clean install

printc "  Compile and install [pfetch]\n" "i"
cd "$SC_FOLDER/pfetch" && sudo make install

printc "  Returning to project folder\n" "i"
cd "$USER_HOME/$PROJECT"

printc "  Creating configurations files\n" "i"
# .dwm autostart
cp -r "$CF_FOLDER/.dwm" "$USER_HOME/"
sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.dwm"

printc "  Setting shell for root as /bin/bash\n" "i"
sudo chsh -s /bin/bash

if [ $(sudo grep "NOPASSWD: /bin/shutdown" /etc/sudoers | wc -l) -eq 0 ]; then
	printc "  Remove password for grou wheel for command shutdown\n" "i"
	sudo echo "## Remove password for shutdown command for users on group of wheel" >> /etc/sudoers
	sudo echo "%wheel ALL=(ALL:ALL) NOPASSWD: /bin/shutdown" >> /etc/sudoers
fi


# Configs dot files - nvim - tmux - etc
printc "  Install my configs\n" "i"
git clone https://gitlab.com/lpg2709/dotfiles "$USER_HOME/dotfiles"
/bin/bash "$USER_HOME/dotfiles/install.sh" "--all"
rm -rf "$USER_HOME/dotfiles"

# dwm entry for lightdm
printc "  Creating dwm.desktop files\n" "i"
sudo cp -r "$CF_FOLDER/xsessions" "/usr/share/"

# add .bashrc
printc "  Copy .bashrc\n" "i"
sudo cp "$CF_FOLDER/.bashrc" "$USER_HOME/.bashrc"
sudo cp "$CF_FOLDER/.bashrc" "/root/.bashrc"
sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.bashrc"

# Set default applications for thunar
printc "  Copy helpers for xfce4\n" "i"
sudo cp -r "$CF_FOLDER/xfce4" "$USER_HOME/.config/"

# Install fonts
printc "  Installing font\n" "i"
tar -xzf "$USER_HOME/$PROJECT/theme/ProggyCleanNF.tar.gz" -C "/tmp"
sudo cp "/tmp/ProggyCleanNF/ProggyCleanTT Nerd Font Complete Mono.ttf" "/usr/share/fonts/TTF"

# Setting keyboard
printc "  Creating30-keyboard files, for abnt keyboard\n" "i"
mkdir -p /etc/X11/
sudo cp -r "$CF_FOLDER/xorg.conf.d" "/etc/X11/"

# theme config
printc "  Setting Gruvbox-Material-Dark to lightdm-greeter\n" "i"
sed -i 's/#theme-name=/theme-name = Gruvbox-Material-Dark/' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#icon-theme-name=/icon-theme-name = Gruvbox-Material-Dark/' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#background=/background = \/usr\/share\/wallpapers\/lpg-linux\/houses.jpg/' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf

printc "  Creating some scripts\n" "i"
cp "$SC_FOLDER/fehbg" "/bin/fehbg"
cp "$SC_FOLDER/pmenu" "/bin/pmenu"
cp "$SC_FOLDER/helpdwm" "/bin/helpdwm"
cp -r "$SC_FOLDER/dwm-help" "/bin/dwm-help"

if [ ! -d "/usr/share/wallpapers/$PROJECT" ]; then
	printc "  Copy wallpapers\n" "i"
	sudo mkdir -p "/usr/share/wallpapers/$PROJECT"
	sudo cp -a "$USER_HOME/$PROJECT/img/wallpapers/." "/usr/share/wallpapers/$PROJECT"
fi

if [ $(ls "/usr/share/themes" | grep Gruvbox | wc -l) -eq 0 ]; then
	printc "  Copy Gruvbox theme\n" "i"
	sudo cp -rf "$USER_HOME/$PROJECT/theme/gruvbox-material-gtk/themes/." "/usr/share/themes"
fi

if [ $(ls "/usr/share/icons" | grep Gruvbox | wc -l) -eq 0 ]; then
	printc "  Copy Gruvbox icons\n" "i"
	sudo cp -rf "$USER_HOME/$PROJECT/theme/gruvbox-material-gtk/icons/." "/usr/share/icons"
	printc "  Updating icons cache\n" "i"
	sudo gtk-update-icon-cache "/usr/share/icons/Gruvbox-Material-Dark"
fi

printc "  Setup Gruvbox theme\n" "i"
if [ ! -d "$USER_HOME/.config/gtk-3.0" ]; then
	mkdir -p "$USER_HOME/.config/gtk-3.0" # for the current user
fi
cp "$CF_FOLDER/gtk-3.0/settings.ini" "$USER_HOME/.config/gtk-3.0/"
if [ ! -d "/root/.config/gtk-3.0" ]; then
	mkdir -p "/root/.config/gtk-3.0" # for root
fi
cp "$CF_FOLDER/gtk-3.0/settings.ini" "/root/.config/gtk-3.0/"

sudo chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config"

printc "  Installing programs\n" "i"
sudo xbps-install -Sy ${POST_PACK[@]} -y

if [ ! -L "/var/service/dbus" ]; then
	printc "  Setup dbus service\n" "i"
	ln -s /etc/sv/dbus /var/service
fi
if [ ! -L "/var/service/lightdm" ]; then
	printc "  Setup lightdm service\n" "i"
	ln -s /etc/sv/lightdm /var/service
fi

printc "  Fix delete key on st\n" "i"
echo "set enable-keypad on" >> $USER_HOME/.inputrc
echo "set enable-keypad on" >> /root/.inputrc

printc "  Fixing .Xauthority\n" "i"
touch $USER_HOME/.Xauthority
touch /root/.Xauthority
xauth add ${HOST}:0 . $(xxd -l 16 -p /dev/urandom)

printc "  Fixing gvfs start with dbus session; For Thunar advanced things\n" "i"
sudo sed -i "s/exec $@/exec dbus-run-session $@/" /etc/lightdm/Xsession

printc "\nInstalation finished \\o/\n" "s"

