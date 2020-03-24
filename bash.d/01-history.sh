export HISTSIZE=100000
export HISTFILESIZE=100000
# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL="ignoreboth:erasedups"
export HISTIGNORE="&:ls:[bf]g:exit:history:cat:l:ll:ps:history *:pwd:free:w:jobs:* --help:* -help:* -version:* --version:[^0-9a-zA-Z_[{(#./~]*"

# all history in 1
shopt -s histappend
# CUSTOM_PROMPT_LAST_COMMAND_STATUS is the status of the last command (written
# in zzz-custom-prompt.sh), and 127 exit code is when command not found (or
# some problems with shard libraries, but anyway they are not ignored so the
# problem can be fixed and the command can be repeated).
PROMPT_COMMAND+='[ -v CUSTOM_PROMPT_LAST_COMMAND_STATUS ] && [[ $CUSTOM_PROMPT_LAST_COMMAND_STATUS -ne 127 ]] && history -a ;'
#many strings commands
shopt -s cmdhist
shopt -s histverify
