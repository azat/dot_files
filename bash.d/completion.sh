#
# bash autocomplete, that parse --help of program
# and use autocomplete in bash!
#
# Use: complete -F complete_by_help -o default {BINARY_NAME}
#

# Known to work with bash 3.* with programmable completion and extended
# pattern matching enabled (use 'shopt -s extglob progcomp' to enable
# these if they are not already enabled).
shopt -s extglob

_get_options()
{
    $* --help 2>&1 | fgrep -- - \
        | awk '{for (i=1; i<=NF; i++) print $i}' \
        | awk -F= '{for (i=1; i<=NF; i++) print $i}' \
        | tr -d ',' | tr -d '[' | tr -d ']' \
        | tr -d '(' | tr -d ')' \
        | tr '|' $'\n' \
        | grep -- ^- | grep -v ^-$ | grep -v ^--$ \
        | sort -u
}

complete_by_help()
{
    local cur
    eval local cmd=$( quote "$1" )

    if [ ! -f "$cmd" ] && ! $( whereis $cmd >& /dev/null ); then
        return 0
    fi

    COMPREPLY=()
    cur="$(_get_cword)"
    prev="$(_get_pword)"

    case "$prev" in
        # Argh...  This looks like a bash bug...
        # Redirections are passed to the completion function
        # although it is managed by the shell directly...
        '<'|'>'|'>>'|[12]'>'|[12]'>>')
            return
            ;;
    esac

    COMPREPLY=( $(compgen -W "$(_get_options $cmd)" -- $cur) )

    return 0
}

