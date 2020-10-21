#!/usr/bin/env bash

# configure sudoerr for tee into /sys

function backlight_write()
{
    local sys=$1
    shift

    # we can use bash builtin, but not under sudo, so use tee
    sudo -n tee $sys/brightness > /dev/null
}
function read_file()
{
    local sys=$1 f=$2 val
    shift 2
    read "$@" val < $sys/$f
    echo "$val"
}
function backlight_cur() { read_file "$@" brightness; }
function backlight_max() { read_file "$@" max_brightness; }

function by_key()
{
    declare -A map
    map[keyboard]=/sys/class/leds/tpacpi::kbd_backlight
    map[monitor]=/sys/class/backlight/intel_backlight
    echo ${map[$key]}
}
function main()
{
    local key="$1"
    local action="$2"
    shift 2

    local sys=$(by_key $key)
    [ -z "$sys" ] && exit 1

    local steps=10
    local cur=$(backlight_cur $sys)
    local max=$(backlight_max $sys)
    local step=$((max/steps))

    if [ "$action" = "up" ]; then
        let cur+=$step
        [ $cur -lt $max ] || cur=$max
    elif [ "$action" = "down" ]; then
        let cur-=$step
        [ $cur -gt 0 ] || cur=0
    else
        exit 2
    fi

    backlight_write $sys <<<"$cur" || echo "$sys=$cur [failed]" >&2
}
main "$@"
