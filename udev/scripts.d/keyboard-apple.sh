#!/usr/bin/env bash

# @see keyboard-xset.sh for the reasons
# In a nutshell not always this settings is applied.

logger "$0 -- $ACTION"

# redirect all errors to the syslog
exec 3> >(exec logger)
exec 2> >(exec logger)
export BASH_XTRACEFD=3

TIMEOUT=1

function run_bg()
{
    local o=(
        --setenv ACTION=apply-keymap
        --unit udev-keyboard-apple
        # Now we are in backgroud. Let's wait for some
        # time so X.org can do its own configuration.
        --on-active $TIMEOUT
        --timer-property=AccuracySec=100ms
    )
    systemd-run "${o[@]}" "$@"
}
function apply_keymap()
{
    local xids=(
        $(DISPLAY=:0 xinput list | grep Apple | egrep -o 'id=[0-9]*' | cut -d= -f2)
    )
    local i
    for i in "${xids[@]}"; do
        logger "$0 -- applying keymap for $i"
        xkbcomp -i $i ~azat/.xkeymap.hid_apple.xkb :0
    done

    # to reset-failed systemd unit
    return 0
}

function main()
{
    case "$ACTION" in
        add) run_bg $0 ;;
        apply-keymap) apply_keymap ;;
    esac
}
main "$@"
