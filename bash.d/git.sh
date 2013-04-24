alias git-changelog='git --no-pager log --format="%ai %aN %n%n%x09* %s%d%n"'

GIT_REVIEW_DIFF=$(git config diff.tool) : ${GIT_REVIEW_DIFF:="git diff"}
export GIT_REVIEW_DIFF
