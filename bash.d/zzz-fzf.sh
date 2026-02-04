#
# fzf plugins
#
FZF_CTRL_R_EDIT_KEY=ctrl-e
FZF_CTRL_R_EXEC_KEY=enter
FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+" "}--no-mouse"
# fd interprets .gitignore by default
# NOTE: it does not work for completion (C-T), because of unset FZF_DEFAULT_COMMAND in /usr/share/fzf/completion.bash
if command -v fd >& /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
fi
source "${BASH_SOURCE[0]}"/fzf-history-exec.bash
