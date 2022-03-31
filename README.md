# lpgMint

Installation of my environment using Mint as a base.

## Install

Install Linux Mint, I recomend use XFCE.

With the installation finished, login open the terminal and run the follow
commands:

```sh
sudo apt install git
git clone https://github.com/lpg2709/lpgMint ~/lpgMint
cd lpgMint && sudo ./install.sh
```

On finished, logout from session and select DWM on greeter.

## Features

- [dwm 6.8](https://dwm.suckless.org/)
- [st 0.8.4](https://st.suckless.org/)
- [dmenu 5.0](https://tools.suckless.org/dmenu/)
- [GUI Gruvbox Theme by TheGreatMcPain](https://github.com/TheGreatMcPain/gruvbox-material-gtk)
- [feh](https://feh.finalrewind.org/)
- [pfetch](https://github.com/dylanaraps/pfetch)

## Customisation

The lpgMint repository is saved in the home, to customize it, just change the
necessary files and run the installation script again.

If the customisation is on dwm suite, you can simple run ```sudo make install```
direct on folder of the tool.

### Project directories

- dot-files: configuration files for tmux, vim and gtk3 theme.
- img: Wallpaper images.
- scripts: Scripts and useful executables,
  - fehbg: setup the backgroud image.
  - pmenu: custom menu for dmenu, for logout/reboot/poweroff.
  - dwm.desktop: The program entry for lightdm-greeter.
  - helpdwm: Simple text printer with dwm keybinds.
  - pfetch: simple system information tool in POSIX, clone from original repository.
- suckless: The Suckless suite for this configuration.
- theme: The gruvbox-theme, clone from the original repository.
