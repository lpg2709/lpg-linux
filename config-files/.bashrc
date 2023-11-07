# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lah'

alias so='source ~/.bashrc'
# PS1='[\u@\h \W]\$ '

CL_WHITE_FG="\[\033[00m\]"
CL_YELLOW_FG="\[\033[33m\]"
CL_BLUE_FG="\[\033[34m\]"
CL_GREEN_FG="\[\033[32m\]"
PS1="[$CL_BLUE_FG\u$CL_WHITE_FG@$CL_GREEN_FG\h $CL_YELLOW_FG\w$CL_WHITE_FG]\$ "

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

