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

if [[ -f /usr/share/autojump/autojump.sh ]]
then
    source /usr/share/autojump/autojump.sh
fi
if [[ -f /usr/share/autojump/autojump.bash ]]
then
    source /usr/share/autojump/autojump.bash
fi

# -------- Prompt --------
#modify ps1
PS1='[\[\033[01;38;5;196m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\[\e[036m\] '
#make terminal input blue
trap 'printf "\e[0m" "$_"' DEBUG

# -------- History --------
#increase bash history
HISTFILESIZE=10000000
HISTTIMEFORMAT="%FT%R "
HISTSIZE=10000000
# append to .bash_history and reread after each command
export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# append to .bash_history instead of overwriting
shopt -s histappend
# dont allow repeated lines
export HISTCONTROL=ignoredups:erasedups

# backup history/warn about deleted history
if (( $(wc -l < ~/.bash_history) < 5000 ))
then
    echo "#######################"
    echo ".bash_history was cleared"
    echo "#######################"
else
    cp ~/.bash_history ~/.bash_history.back
fi

