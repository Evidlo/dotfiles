# .bash_profile

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment and startup programs

export HISTSIZE=10000
PATH=$PATH:/home/evan/resources/scripts:$(find $HOME/bin/ -type d -printf "%p:")$HOME/.local/bin:/usr/local/MATLAB/R2013a/bin:/usr/local/bin:$HOME/resources/X6/stm-code/bin
export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.7/site-packages
PS1="[\[\033[01;31m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\$ "
export PATH

alias a='echo hi'
