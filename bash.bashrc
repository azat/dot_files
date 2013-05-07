# System-wide .bashrc file for interactive bash(1) shells.
#
# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f /etc/bash_functions ] ; then
    . /etc/bash_functions
fi

export HISTSIZE=3000
# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL="ignoreboth:erasedups"
export HISTIGNORE="&:ls:[bf]g:exit:history:cat:l:ll:ps:history *:pwd:free:w:jobs"

# all history in 1
shopt -s histappend
PROMPT_COMMAND='history -a'
#many strings commands
shopt -s cmdhist

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set window title
# Redhat way
case $TERM in
	xterm*|rxvt*)
		PROMPT_COMMAND="$PROMPT_COMMAND; "'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
	;;
	screen)
		PROMPT_COMMAND="$PROMPT_COMMAND; "'printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
	;;
esac

# Load "bash.d" directory files
if [ -d /etc/bash.d ] ; then
	for bash_d_it in $( ls /etc/bash.d/*.sh ); do
		. $bash_d_it
	done
fi
unset bash_d_it

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
	 alias lss='ls --color=never'
	 alias grep='grep --color=auto'
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias tm='tmux attach || tmux new'
alias sortfast="sort -S$(($(sed '/MemT/!d;s/[^0-9]*//g' /proc/meminfo)/1024-200)) --parallel=$(($(grep -c ^proc /proc/cpuinfo)*2))"
alias save_kde_session='qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.saveCurrentSession'

# This line was appended by KDE
# Make sure our customised gtkrc file is loaded.
# export GTK2_RC_FILES=$HOME/.gtkrc-2.0

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable tab completion after some of commands
complete -cf sudo
complete -cf gksu
complete -cf kdesudo
complete -cf whereis
complete -cf watch

