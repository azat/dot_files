alias git-changelog='git --no-pager log --format="%ai %aN %n%n%x09* %s%d%n"'

function git_ahead_behind
{
    curr_branch=$(git rev-parse --abbrev-ref HEAD);
    curr_remote=$(git config branch.$curr_branch.remote);
    curr_merge_branch=$(git config branch.$curr_branch.merge | cut -d / -f 3);
    git rev-list --left-right --count $curr_branch...$curr_remote/$curr_merge_branch | tr -s '\t' '|';
}

GIT_REVIEW_DIFF=$(git config diff.tool) : ${GIT_REVIEW_DIFF:="git diff"}
export GIT_REVIEW_DIFF
