#!/bin/bash

# Import other functions
source "./libs/commons.sh"

DWM="dwm-6.2"
DMENU="dmenu-5.0"
ST="st-0.8.4"
CHECK_FILE="/opt/lpg_debian_reset0"

DEPS_PACK=("vim" "make" "build-essential" "libx11-dev" "libxft-dev" "libxinerama-dev" "xorg" "fonts-font-awesome" "feh" "xdg-user-dirs")
POST_PACK=("tmux" "net-tools" "python3" "htop" "jq" "firefox-esr" "thunar" "cmake" "tcpdump" "baobab" "gnome-disk-utility")

check_root

if [ ! -f "$CHECK_FILE" ]; then
	./setup.sh
else

	printc "  Continuing instalation...\n" "i"
	printc "  Installing dependencis\n" "i"
	sudo apt install ${DEPS_PACK[@]} -y

	USERNAME=$(cat "$CHECK_FILE")
	U_FOLDER="/home/$USERNAME"
	S_FOLDER="$U_FOLDER/$PROJECT/suckless"
	CF_FOLDER="$U_FOLDER/$PROJECT/config-files"
	SC_FOLDER="$U_FOLDER/$PROJECT/scripts"

	printc "  Compile and install [dwm-6.2]\n" "i"
	cd "$S_FOLDER/$DWM" && sudo make clean install
	printc "  Compile and install [st-0.8.4]\n" "i"
	cd "$S_FOLDER/$ST" && sudo make clean install
	printc "  Compile and install [dmenu-5.0]\n" "i"
	cd "$S_FOLDER/$DMENU" && sudo make clean install

	printc "  Compile and install [pfetch]\n" "i"
	cd "$SC_FOLDER/pfetch" && sudo make install

	printc "  Creating configurations files\n" "i"
	# .xinit
	cp "$CF_FOLDER/.xinitrc" "$U_FOLDER/.xinitrc"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/.xinitrc"
	# bash_profile
	cp "$CF_FOLDER/.bash_profile" "$U_FOLDER/.bash_profile"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/.bash_profile"
	# .tmux
	bash -c  "$(wget -qO- https://git.io/JCbIh)"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/.tmux.conf"
	# .vimrc
	bash -c  "$(wget -qO- https://git.io/JCbTi)"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/.vimrc"

	printc "  Creating some folders\n" "i"
	xdg-user-dirs-update
	mkdir "$U_FOLDER/Suckless" "$U_FOLDER/.config"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/Suckless" "$U_FOLDER/.config"

	printc "  Copy Suckless programs\n" "i"
	cp "$S_FOLDER/$DWM" "$U_FOLDER/Suckless/$DWM"
	cp "$S_FOLDER/$ST" "$U_FOLDER/Suckless/$ST"
	cp "$S_FOLDER/$DMENU" "$U_FOLDER/Suckless/$DMENU"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/Suckless/$DWM" "$U_FOLDER/Suckless/$ST" "$U_FOLDER/Suckless/$DMENU"

	printc "  Creating some scripts\n" "i"
	cp "$SC_FOLDER/fehbg" "/bin/fehbg"
	cp "$SC_FOLDER/pmenu" "/bin/pmenu"
	cp "$SC_FOLDER/helpdwm" "/bin/helpdwm"
	cp -r "$SC_FOLDER/dwm-help" "/bin/dwm-help"

	printc "  Copy wallpapers\n" "i"
	sudo mkdir "/usr/share/wallpapers" "/usr/share/wallpapers/lpgDebian"
	sudo cp -a "$U_FOLDER/$PROJECT/img/wallpapers/." "/usr/share/wallpapers/lpgDebian"

	printc "  Copy Gruvbox theme\n" "i"
	sudo cp -rf "$U_FOLDER/$PROJECT/theme/gruvbox-material-gtk/themes/." "/usr/share/themes"
	sudo cp -rf "$U_FOLDER/$PROJECT/theme/gruvbox-material-gtk/icons/." "/usr/share/icons"
	sudo gtk-update-icon-cache "/usr/share/icons/Gruvbox-Material-Dark"

	printc "  Setup Gruvbox theme\n" "i"
	mkdir "$U_FOLDER/.config/gtk-3.0"
	cp -rf "$CF_FOLDER/gtk-3.0/settings.ini" "$U_FOLDER/.config/gtk-3.0"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/.config/gtk-3.0"

	printc "  Installing programs\n" "i"
	sudo apt install ${POST_PACK[@]} -y

	printc "\nInstalation finished \o/\n" "s"
	printc "Cleaning files and prepering for reboot\n" "s"

	sudo rm "$U_FOLDER/.bashrc"
	sudo rm "$CHECK_FILE"
	sudo rm -rf "/root/$PROJECT"
	mv "$U_FOLDER/.bashrc_old" "$U_FOLDER/.bashrc"
	sudo chown  "$USERNAME:$USERNAME" "$U_FOLDER/.bashrc"
	sudo apt autoremove

	reboot_ "sudo"
fi

