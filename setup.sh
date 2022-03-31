#!/bin/bash

source ./libs/commons.sh

CHECK_FILE="/opt/lpg_debian_reset0"
INIT_PACK=("git" "curl" "wget" "sudo")

printc "\nStarting installation...\n" "i"
printc "  Inform the current user to add to sudoers: " "l"
read USERNAME

if [ -z "$USERNAME" ]; then
	printc "User name can't be empity!\n" "e"
	exit 1
fi

id "$USERNAME" &>/dev/null
if [ ! "$?" -eq "0" ]; then
	printc "User not found!\n" "e"
	exit 1
fi
U_FOLDER="/home/$USERNAME"

printc "  Updating the system\n" "i"
apt update && apt upgrade -y

printc "  Installing base packages\n" "i"
apt install ${INIT_PACK[@]} -y

printc "  Update user to sudoers group\n" "i"
usermod -aG sudo "$USERNAME"

echo "$USERNAME" > "$CHECK_FILE"
cp "$U_FOLDER/.bashrc" "$U_FOLDER/.bashrc_old"
	chown "$USERNAME:$USERNAME" "$U_FOLDER/.bashrc"
cp -r "$C_FOLDER" "$U_FOLDER"
chown "$USERNAME:$USERNAME" "$C_FOLDER"
echo "cd $U_FOLDER/$PROJECT && sudo ./install.sh" >> "$U_FOLDER/.bashrc"

reboot_
