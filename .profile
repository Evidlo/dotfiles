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

# -------- PATH --------
# add bin and subdirectories to path if it exists
if [[ -d $HOME/bin ]]
then
    PATH=$(find -L $HOME/bin/ -type d -printf ":%p"):$PATH
fi
# add scripts folder to path if it exists
if [[ -d $HOME/resources/scripts ]]
then
    PATH=$PATH:$HOME/resources/scripts
fi
#go configuration
if [[ -d $HOME/resources/go ]]
then

    GOPATH=$HOME/resources/go
    GOBIN=$HOME/resources/go/bin
    export GOPATH
    export GOBIN
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
# add rust bin to path if it exists
if [[ -d $HOME/.cargo/bin ]]
then
    PATH=$PATH:$HOME/.cargo/bin
fi
# add bpkg bin to path if it exists
if [[ -d $HOME/deps/bin ]]
then
    PATH=$PATH:$HOME/deps/bin
fi
# add go bin to path if it exists
if [[ -d $HOME/resources/go/bin ]]
then
    PATH=$PATH:$HOME/resources/go/bin
fi
# add local node path if it exists
if [[ -d $HOME/.node ]]
then
    PATH=$PATH:$HOME/.node/bin
    NODE_PATH=$HOME/.node/lib/node_modules:$NODE_PATH
    MANPATH=$HOME/.node/share/man:$MANPATH
    export NODE_PATH
    export MAN_PATH
fi

export PATH

# -------- Aliases --------
alias ls="ls --color=auto"
alias e="emacsclient -tc"
alias emacs="emacsclient -c"
function rootname(){ echo "${1%.*}"; }

#Start and EXit - function to start a command in the background and close terminal (useful for opening pdfs)
sex(){ ("$@" <>/dev/null >&0 2>&0 &) ; exit ;}

export PATH="$HOME/.cargo/bin:$PATH"
