# see https://github.com/tmuxinator/tmuxinator/issues/253#issuecomment-252419510
function mux()
{
    [ $# -eq 1 ] || return
    local s="$1"
    shift

    local p=~/.tmuxinator/"$s.sh"

    # XXX: works only when socket_name == tmuxinator name
    tmux -L $s a || {
        tmuxinator debug "$s" >| "$p"
        chmod +x "$p"
        "$p"
    }
}
