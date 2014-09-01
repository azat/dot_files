export HISTSIZE=100000
# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL="ignoreboth:erasedups"
export HISTIGNORE="&:ls:[bf]g:exit:history:cat:l:ll:ps:history *:pwd:free:w:jobs"

# all history in 1
shopt -s histappend
PROMPT_COMMAND+='; history -a'
#many strings commands
shopt -s cmdhist
