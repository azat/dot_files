if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias wdiff='wdiff -w "$(tput bold;tput setaf 1)" -x "$(tput sgr0)" -y "$(tput bold;tput setaf 2)" -z "$(tput sgr0)"'
fi

alias ll='ls -l'
alias tm='tmux attach || tmux new'
alias sortfast="sort -S$(($(sed '/MemT/!d;s/[^0-9]*//g' /proc/meminfo)/1024-200)) --parallel=$(($(grep -c ^proc /proc/cpuinfo)*2))"
alias strings='strings -a'
alias gdb='gdb -q'

alias gg='git grep'

alias mosh='MOSH_ESCAPE_KEY="" mosh'

alias xargs='xargs -r'
