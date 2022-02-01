export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL="ignoreboth:erasedups"

HISTIGNORE="&:ls:[bf]g:exit:history:cat:l:ll:ps:history *:pwd:free:w:jobs"
HISTIGNORE+=":* --help:* -help:* -version:* --version:[^0-9a-zA-Z_[{(#./~]*"
HISTIGNORE+="reboot:poweroff:* reboot:* shutdown"
HISTIGNORE+=":[^0-9a-zA-Z_[{(#./~]*"
export HISTIGNORE

shopt -s histappend
shopt -s cmdhist
shopt -s histverify

# CUSTOM_PROMPT_LAST_COMMAND_STATUS is the status of the last command (written
# in zzz-custom-prompt.sh), and 127 exit code is when command not found (or
# some problems with shard libraries, but anyway they are not ignored so the
# problem can be fixed and the command can be repeated).
PROMPT_COMMAND+='[ -v CUSTOM_PROMPT_LAST_COMMAND_STATUS ] && [[ $CUSTOM_PROMPT_LAST_COMMAND_STATUS -ne 127 ]]; '
# "history -a" is not compatible with "erasedups",
# i.e. eventually the file will have duplicates.
#
# There is a "workaround" for this problem:
#     "history -n; history -w; history -c; history -r"
#
# But this has the following drawbacks:
# - "history -c" will clear the $HISTFILE (i.e. if it will be executed from shell)
# - it will not be enough to edit $HISTFILE and remove some entry from this
#   (i.e. entry with the password), since now it first reads the file.
# - this will overlap history from different shells (and this is not what I want)
PROMPT_COMMAND+='history -a ;'
