
function svn()
{
    case "$1" in
        grep)
            shift
            command grep --exclude='*.svn-*' --exclude='entries' "$@"
            ;;
        commit-revert)
            command svn merge -c -$2 ${3:-"."}
            ;;
        show)
            command svn diff -c $2
            ;;
        *)
            command svn "$@"
            ;;
    esac
}

