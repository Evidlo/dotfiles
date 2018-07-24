# Evan Widloski - 2018-07-22

#set keyboard repeat rate
if [ -n "$DISPLAY" ]
then
    xset r rate 200 30
fi

# -------- Application Settings --------
#start emacs daemon if not already running
export EDITOR="emacsclient -tc"
export ALTERNATE_EDITOR=""

#go configuration
if [[ -d $HOME/resources/go ]]
then

    GOPATH=$HOME/resources/go
    GOBIN=$HOME/resources/go/bin
    export GOPATH
    export GOBIN
fi

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
# if [[ -d $HOME/.pyenv ]]
# then
#     PATH=$PATH:$HOME/.pyenv/bin
#     eval "$(pyenv init -)"
# fi
if [[ -d $HOME/resources/venv3 ]]
then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    source $HOME/resources/venv3/bin/activate
fi
if [[ -d $HOME/.cargo/bin ]]
then
    PATH=$PATH:$HOME/.cargo/bin
fi
if [[ -d $HOME/resources/go/bin ]]
then
    PATH=$PATH:$HOME/resources/go/bin
fi

export PATH

# -------- Aliases --------
alias ls="ls --color=auto"
alias e="emacsclient -tc"
alias emacs="emacsclient -c"

#Start and EXit - function to start a command in the background and close terminal (useful for opening pdfs)
sex(){ ("$@" <>/dev/null >&0 2>&0 &) ; exit ;}
