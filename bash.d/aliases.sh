if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
    alias lss='ls --color=never'
    alias grep='grep --color=auto'
fi

alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias tm='tmux attach || tmux new'
alias sortfast="sort -S$(($(sed '/MemT/!d;s/[^0-9]*//g' /proc/meminfo)/1024-200)) --parallel=$(($(grep -c ^proc /proc/cpuinfo)*2))"
alias save_kde_session='qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.saveCurrentSession'
alias f='find ./ -name'
alias strings='strings -a'
