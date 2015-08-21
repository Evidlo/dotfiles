# .bash_profile

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment and startup programs

export HISTSIZE=10000
PATH=$PATH:/home/evan/resources/scripts:$(find $HOME/bin/ -type d -printf "%p:")/usr/local/bin
PS1="[\[\033[01;31m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\$ "
export PATH

alias ls="ls --color=auto"

#set to vim mode
set -o vi
