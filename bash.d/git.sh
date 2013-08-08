function git_ahead_behind
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

