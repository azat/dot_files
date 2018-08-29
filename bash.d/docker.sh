# fix terminal settings for interactive sessions
function docker()
{
    # non interactive
    [[ "$*" =~  \ (-i|--interactive) ]] || {
        command docker "$@"
        return
    }

    local action="$1"
    # we have at least one argument anyway
    shift || return 127

    local args=(
        -e COLUMNS=$(tput cols)
        -e LINES=$(tput lines)
        -e TERM=xterm
    )
    case "$action" in
        exec|run) command docker "$action" "${args[@]}" "$@" ;;
        *) command docker "$action" "$@" ;;
    esac
    return
}
