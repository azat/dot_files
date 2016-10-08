# If not running interactively, don't do anything
[ -z "$PS1" ] && return

shopt -s checkwinsize

PROMPT_COMMAND=''
for bash_d_it in /etc/bash.d/*.sh; do
    . $bash_d_it
done 2>/dev/null
unset bash_d_it

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
