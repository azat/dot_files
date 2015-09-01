function linux_ctags()
{
    local arch=${1:-"x86"}

    eval ctags --recurse \
        "$(ls -1d arch/* | fgrep -v $arch | xargs printf '--exclude=%s/* ')" \
        --exclude='drivers/*' \
        --exclude=build*/* \
        --exclude=debian/* \
        "$@" \
        --exclude=sound/* .
}
