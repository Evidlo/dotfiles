# .bash_profile
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

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


#increase bash history
export HISTSIZE=10000

#add script folder and bin subfolders to path
PATH=$PATH:/home/evan/resources/scripts:$(find $HOME/bin/ -type d -printf "%p:")/usr/local/bin
export PATH

#modify ps1
PS1="[\[\033[01;31m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\$ "

#start emacs daemon if not already running
export ALTERNATE_EDITOR=""

#go configuration
GOPATH=/home/evan/resources/go
export GOPATH

#Start and EXit - function to start a command in the background and close terminal (useful for opening pdfs)
sex(){ ("$@" <>/dev/null >&0 2>&0 &) ; exit ;}

alias ls="ls --color=auto"
alias e="emacsclient -tc"

#set to vim mode
set -o vi

#set keyboard repeat rate
if [ -n "$DISPLAY" ]
then
    xset r rate 200 30
fi
