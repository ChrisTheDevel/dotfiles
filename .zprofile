export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/bin/status_bar"
export PATH="$PATH:$HOME/.local/rofi"

export EDITOR="helix"
export TERMINAL="alacritty"
export BROWSER="brave"

source /usr/share/nvm/init-nvm.sh

[ -f "/home/fincei/.ghcup/env" ] && source "/home/fincei/.ghcup/env" # ghcup-env
[ -f "/usr/share/nvm/init-nvm.sh" ] && source "/usr/share/nvm/init-nvm.sh"

# If not using a display manager (login) then the below can be used to automatically
# start a graphical session on login.
if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
