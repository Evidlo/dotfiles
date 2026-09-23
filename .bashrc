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
if [[ -f /usr/share/fzf/shell/key-bindings.bash ]]
then
    source /usr/share/fzf/shell/key-bindings.bash
fi


# -------- Prompt --------
#modify ps1
PS1='[\[\033[01;38;5;196m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]]\[\e[036m\] '
#make terminal input blue
trap 'printf "\e[0m" "$_"' DEBUG

# -------- History --------

# shared history directory for all devices
HISTDIR=~/secrets/history
HISTSIZE=10000000
HISTFILESIZE=10000000
HISTTIMEFORMAT="%FT%R "
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend

if [ -d "$HISTDIR" ]; then
    HISTFILE="$HISTDIR/bash_history.$(hostname)"
    # load history from other devices
    for hist in "$HISTDIR"/bash_history.*; do
        [ -r "$hist" ] && history -r "$hist"
    done
    # advance the append pointer so the reads above are not written back
    history -a /dev/null 2>/dev/null
    unset hist
fi

# bash has a bug that can cause history to be deleted!
# check the length of the history at startup and make a backup
if (( $(wc -l < "$HISTFILE" 2>/dev/null || echo 0) < 10000 ))
then
    echo "#######################"
    echo "$HISTFILE was cleared"
    echo ""
    echo "WARNING!"
    echo ""
    echo "#######################"
else
    mkdir -p "${HISTFILE%/*}/backups"
    cp "$HISTFILE" "${HISTFILE%/*}/backups/${HISTFILE##*/}"
fi

# append this session's new commands to our own histfile after each command
export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# -------- Profile/aliases --------

source ~/.profile

alias l="exa -l --git --group-directories-first --group"
alias la="exa -al --git --group-directories-first --group"
alias ll="exa -l --git --group-directories-first -T --level=2"

# >>> conda initialize >>>
# <<< conda initialize <<<
