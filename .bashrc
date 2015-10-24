# .bash_profile

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
