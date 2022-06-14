autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch
unsetopt beep notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/fincei/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias \
    cp="cp -iv" \
    mv="mv -iv" \
    rm="rm -vI" \
    ls="exa --icons" \
    grep="grep --color=auto" \
    e="$EDITOR" \
    p="sudo pacman" \
    btw="neofetch" \
    hx="helix" \
    config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"


eval "$(zoxide init zsh --cmd cd)"
# Make bat be used as the pager for man
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# Load some zsh plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
