# Void

Installation of my environment using Void as a base.

## Install

Install Void Linux base.

With the installation finished, login open the terminal and run the follow
commands:

```sh
sudo xbps-install -Rsy git
git clone https://github.com/lpg2709/lpg-linux
cd lpg-linux
git checkout Void
sudo ./install.sh
```

On finished, reboot:

```sh
sudo shutdown -r now
```

## Features

- [dwm 6.4](https://dwm.suckless.org/)
- [st 0.9.2](https://st.suckless.org/)
- [dmenu 5.0](https://tools.suckless.org/dmenu/)
- [GUI Gruvbox Theme by TheGreatMcPain](https://github.com/TheGreatMcPain/gruvbox-material-gtk)
- [feh](https://feh.finalrewind.org/)
- [pfetch](https://github.com/dylanaraps/pfetch)

### Project directories

- config: configuration files
- img: Wallpaper images.
- scripts: Scripts and useful executables,
  - fehbg: setup the backgroud image.
  - pmenu: custom menu for dmenu, for logout/reboot/poweroff.
  - dwm.desktop: The program entry for lightdm-greeter.
  - helpdwm: Simple text printer with dwm keybinds.
  - pfetch: simple system information tool in POSIX, clone from original repository.
- suckless: The Suckless suite for this configuration.
- theme: The gruvbox-theme, clone from the original repository.
