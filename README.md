# WindowsW

My configuration for WSL. 

> Current using Debian

## How use

After install and setup WSL distribution, close the program window, open WSL and run the follow commands:

```sh
sudo apt update && sudo apt install -y git
git clone https://gitlab.com/lpg2709/lpg-linux && \
  cd lpg-linux && \
  git checkout WindowsW && \
  sudo ./install.sh
```
