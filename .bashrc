# .bash_profile

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment and startup programs

export HISTSIZE=10000
PATH=$PATH:/home/evan/resources/scripts:$(find $HOME/bin/ -type d -printf "%p:")/usr/local/bin
PS1="[\[\033[01;31m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\$ "
export PATH

#start emacs daemon if not already running
export ALTERNATE_EDITOR=""

GOPATH=/home/evan/resources/go
export GOPATH

alias ls="ls --color=auto"
alias e="emacsclient -tc"

#set to vim mode
set -o vi
