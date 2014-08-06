function git_ahead_behind()
{
    curr_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    curr_remote=$(git config branch.$curr_branch.remote)
    if [ -z "$curr_remote" ]; then
        echo "0|0"
        return
    fi
    curr_merge_branch=$(git config branch.$curr_branch.merge | cut -d / -f 3)
    diff=$(git rev-list --left-right --count $curr_branch...$curr_remote/$curr_merge_branch 2>/dev/null)
    if [ -z "$diff" ]; then
        echo "N"
        return
    fi
    echo "$diff" | tr -s '\t' '|'
}

GIT_REVIEW_DIFF=$(git config diff.tool) : ${GIT_REVIEW_DIFF:="git diff"}
export GIT_REVIEW_DIFF

#
# Change directory relative to git root.
#
function git_cd()
{
    local dir="$1"
    if [ ! ${dir:0:1} = "/" ]; then
        dir="$(git rev-parse --git-dir)/../$dir"
    fi
    cd $dir
}
function _git_cd_completion()
{
    local cur="$(_get_cword)"

    if [ -z $cur ]; then
        cur="$(readlink -f $(git rev-parse --git-dir)/../$(_get_cword))/"
    fi

    _filedir
}
complete -F _git_cd_completion git_cd

#
# short stat
#
git_stat()
{
    verbose=0
    while getopts "vh" o; do
        case "$o" in
            v)   verbose=$((verbose+1)) ;;
            h)   echo "Usage: git_stat [-v] [-s]"; return 0 ;;
            \?)  echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done

    for i in $(git ls-files); do
        if [ ! -f $i ]; then
            continue;
        fi
        if [[ $verbose -gt 0 ]]; then
            echo "Processing $i" >&2
        fi

        git blame --line-porcelain $i | sed -n 's/^author //p'
    done | sort | uniq -c | sort -rn
}

git_avg()
{
    for i in $(git log --format=%h "$@"); do
        echo -n "$i " >& 2
        git log --format=%B $i -1 | tee -a >(head -1) | tail -n+2 | wc
    done |& awk '\
{
    if (!$2) {
        print "Empty commit " $1;
    }
    lines += $2;
    words += $3;
    bytes += $4;
    ++commits;
}
END {
    printf("Commits: %.0f\n", commits);
    printf("Avg commit length: %.1f\n", (lines / commits));
    printf("Avg commit words: %.0f\n", (words / commits));
    printf("Avg commit bytes: %.0f\n", (bytes / commits));
}
'
}

git_cmake_each()
{
    local upstream=${1:-"origin/master"}
    shift

    local a=""
    [ ! -z "$@" ] && a="&& $@"
    git rebase -i --exec "cd `git rev-parse --git-dir`/../.cmake && make $a" "$upstream"
}

