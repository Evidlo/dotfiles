#!/bin/sh

# Evan Widloski - 2018-07-22

#set keyboard repeat rate
if [ -n "$DISPLAY" ]
then
    xset r rate 200 30
    dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP 2>/dev/null
fi

# change cursor to blinking pipe
# echo -e "\033[5 q"

# -------- Application Settings --------
#start emacs daemon if not already running
export EDITOR="emacsclient -tc"
export ALTERNATE_EDITOR=""
# dont prompt to restart services constantly
export DEBIAN_FRONTEND=noninteractive

# -------- PATH --------
# add bin and subdirectories to path if it exists
if [ -d "$HOME/bin" ]
then
    PATH=$HOME/bin:$PATH
    # PATH=$(find -L $HOME/bin/ -type d -printf ":%p"):$PATH
fi
# add local bin
if [ -d "$HOME/.local/bin" ]
then
    PATH=$HOME/.local/bin:$PATH
fi
# add scripts folder to path if it exists
if [ -d "$HOME/resources/scripts" ]
then
    PATH=$PATH:$HOME/resources/scripts
fi
#go configuration
GOPATH=$HOME/resources/go
GOBIN=$HOME/resources/go/bin
if [ -d "$HOME/resources/go" ]
then

    export GOPATH
    export GOBIN
fi
if [ -d /usr/local/go ]
then
    PATH=$PATH:/usr/local/go/bin
fi
# add homebrew
if [ -d /home/linuxbrew/.linuxbrew ]
then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
# add ruby
if [ -d "$HOME/.gem/ruby/2.7.0/bin" ]
then
    PATH=$PATH:$HOME/.gem/ruby/2.7.0/bin
fi
# add rust bin to path if it exists
if [ -d "$HOME/.cargo/bin" ]
then
    PATH=$PATH:$HOME/.cargo/bin
    [ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi
# add bpkg bin to path if it exists
if [ -d "$HOME/deps/bin" ]
then
    PATH=$PATH:$HOME/deps/bin
fi
# add go bin to path if it exists
if [ -d "$HOME/resources/go/bin" ]
then
    PATH=$PATH:$HOME/resources/go/bin
fi
# add local node path if it exists
if [ -d "$HOME/.node" ]
then
    PATH=$PATH:$HOME/.node/bin
    NODE_PATH=$HOME/.node/lib/node_modules:$NODE_PATH
    MANPATH=$HOME/.node/share/man:$MANPATH
    export NODE_PATH
    export MAN_PATH
fi
# add flatpak exports
if [ -d /var/lib/flatpak/exports/bin ]
then
    PATH=$PATH:/var/lib/flatpak/exports/bin
fi
# add nix-profile
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]
then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
# add default flox environment bin, so tools launched from i3 (not just
# interactive shells that run `flox activate` below) find flox-installed tools
if [ -d "$HOME/.local/flox/.flox/run/$(uname -m)-linux.flox/bin" ]
then
    PATH="$HOME/.local/flox/.flox/run/$(uname -m)-linux.flox/bin:$PATH"
fi

# activate default flox environment if present.
# Interactive shells only: `flox activate` emits `set +h` (a bash builtin
# option dash rejects), and /etc/X11/Xsession sources this file under `set -e`,
# so running it at login aborts the whole X session back to the greeter.
case $- in
*i*)
    if [ -d "$HOME/.local/flox/.flox" ] && command -v flox >/dev/null 2>&1
    then
        eval "$(flox activate -d "$HOME/.local/flox" 2>/dev/null)"
        # drop the "flox [flox]" prompt prefix
        export FLOX_PROMPT_ENVIRONMENTS=""
        [ -n "${FLOX_SAVE_BASH_PS1:-}" ] && PS1="$FLOX_SAVE_BASH_PS1"
    fi
    ;;
esac
# if [ -d $HOME/.pyenv ]
# then
#     PATH=$PATH:$HOME/.pyenv/bin
#     eval "$(pyenv init -)"
# fi
if [ -d "$HOME/resources/venv3" ]
then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    . "$HOME/resources/venv3/bin/activate"
    export PYTHON3_HOST_PROG="$HOME/resources/venv3/bin/python"
    # flox activate (above) exports PYTHONPATH pointing at its python3.14
    # site-packages; venv activation doesn't clear it, so those 3.14 packages
    # (lxml, pykeepass) shadow venv3's 3.13 ones and break on ABI mismatch.
    # venv3 is self-contained, so drop the inherited PYTHONPATH.
    unset PYTHONPATH
fi
if [ -d "$HOME/miniconda3" ]
then
    . "$HOME/miniconda/bin/activate"
fi
if [ -d "$HOME/resources/venv" ]
then
    export PYTHON_HOST_PROG="$HOME/resources/venv/bin/python"
fi

export PATH

# -------- Aliases --------
alias ls="ls --color=auto"
# alias e="emacsclient -tc"
#alias emacs="emacsclient -c"
# An emacs 'alias' with the ability to read from stdin
alias bat="batcat"
rootname() { echo "${1%.*}"; }

#Start and EXit - function to start a command in the background and close terminal (useful for opening pdfs)
sex(){ ("$@" <>/dev/null >&0 2>&1 &) ; exit ;}
alias l="exa -l --git --group-directories-first --group"
alias la="exa -al --git --group-directories-first --group"
alias ll="exa -l --git --group-directories-first -T --level=2"
