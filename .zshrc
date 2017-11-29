# Evan Widloski - 2016-10-29

# -------- Misc zsh --------
# autocomplete
zstyle :compinstall filename '/home/evan/.zshrc'
autoload -Uz compinit && compinit

# -------- History --------
# history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt appendhistory
bindkey -v

# bind history search to ^R
bindkey '^R' history-incremental-pattern-search-backward

# -------- Prompt --------
autoload -U colors && colors
PROMPT="[%{$fg_bold[red]%}%n@%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$reset_color%}] "
zle_highlight+=( default:fg=cyan )

# -------- PATH --------
# add script folder and bin subfolders to path
# if [ -d $HOME/bin ]
# then
#     PATH=$(find $HOME/bin/ -type d -printf ":%p"):$PATH
# fi
# if [ -d $HOME/resources/scripts ]
# then
#     PATH=$PATH:$HOME/resources/scripts
# fi

# -------- Emacs --------

#start emacs daemon if not already running
export ALTERNATE_EDITOR=""

# -------- Aliases --------

alias ls="ls --color=auto"
alias e="emacsclient -tc"
alias emacs="emacsclient -c"

# `Start and EXit` - function to start a command in the background
#                    and close terminal (useful for opening pdfs)
sex(){ ("$@" <>/dev/null >&0 2>&0 &) ; exit ;}

source ~/resources/ros/install_isolated/setup.zsh
