# Evidlo bashrc
# 2016-01-13

# -------- Misc bash --------
#exit if scp
[ -z "$PS1" ] && return

#colors for ttys
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0000000"
    echo -en "\e]P82B2B2B"
    echo -en "\e]P1D75F5F"
    echo -en "\e]P9FF0000"
    echo -en "\e]P200CD00"
    echo -en "\e]PA98E34D"
    echo -en "\e]P3CDCD00"
    echo -en "\e]PBCDCD00"
    echo -en "\e]P40000FF"
    echo -en "\e]PC0000FF"
    echo -en "\e]P5BD53A5"
    echo -en "\e]PDD633B2"
    echo -en "\e]P65FAFAF"
    echo -en "\e]PE44C9C9"
    echo -en "\e]P7E5E5E5"
    echo -en "\e]PFFFFFFF"
    clear #for background artifacting
fi

#source default bashrc
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#set to vim mode
set -o vi

#set keyboard repeat rate
if [ -n "$DISPLAY" ]
then
    xset r rate 200 30
fi

if [[ -f /usr/share/autojump/autojump.sh ]]
then
    source /usr/share/autojump/autojump.sh
fi

# -------- Prompt --------
#modify ps1
PS1='[\[\033[01;38;5;196m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\[\e[036m\] '
#make terminal input blue
trap 'printf "\e[0m" "$_"' DEBUG

# -------- History --------
#increase bash history
HISTFILESIZE=10000000
HISTSIZE=10000000
# append to .bash_history and reread after each command
export PROMPT_COMMAND="history -a;"
# append to .bash_history instead of overwriting
shopt -s histappend
# dont allow repeated lines
export HISTCONTROL=ignoredups:erasedups

# -------- PATH --------
#add script folder and bin subfolders to path
if [[ -d $HOME/bin ]]
then
    PATH=$(find $HOME/bin/ -type d -printf ":%p"):$PATH
fi
if [[ -d $HOME/resources/scripts ]]
then
    PATH=$PATH:$HOME/resources/scripts
fi
if [[ -d $HOME/.pyenv ]]
then
    PATH=$PATH:$HOME/.pyenv/bin
    eval "$(pyenv init -)"
fi
if [[ -d $HOME/.cargo/bin ]]
then
    PATH=$PATH:$HOME/.cargo/bin
fi

export PATH

# -------- Application Settings --------
#start emacs daemon if not already running
export ALTERNATE_EDITOR=""

#go configuration
if [[ -f $HOME/resources/go ]]
then

    GOPATH=/home/evan/resources/go
    export GOPATH
fi

# -------- Aliases --------
alias ls="ls --color=auto"
alias e="emacsclient -tc"
alias emacs="emacsclient -c"
#Start and EXit - function to start a command in the background and close terminal (useful for opening pdfs)
sex(){ ("$@" <>/dev/null >&0 2>&0 &) ; exit ;}

