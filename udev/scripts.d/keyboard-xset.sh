#!/usr/bin/env bash

# All info was obtained from:
#   https://bugzilla.redhat.com/show_bug.cgi?id=601853#c15
#
# The only think I did is:
# - use logger(1), since otherwise you will not see output/errors
# - use systemd-run over nohup in bg, since it will be killed
#   plus using systemd-run has another cons, it will not schedule the same unit
#   twice (since now there is two ACTION=add calls)

logger "$0 -- $ACTION"

# redirect all errors to the syslog
exec 3> >(exec logger)
exec 2> >(exec logger)
export BASH_XTRACEFD=3

TIMEOUT=1

function run_bg()
{
    local o=(
        --setenv ACTION=setautorepeat
        --unit udev-keyboard-xset
        # Now we are in backgroud. Let's wait for some
        # time so X.org can do its own configuration.
        --on-active $TIMEOUT
        --timer-property=AccuracySec=100ms
    )
    systemd-run "${o[@]}" "$@"
}
function main()
{
    case "$ACTION" in
        add)
            # A keyboard has been plugged. It's useless to run xset here
            # because X.org configuration will run *after* this udev script.
            # Just "register" this script to run again in background with
            # different ACTION and exit.
            run_bg $0
            ;;

        setautorepeat)
            # Let's hope:
            # - the configuration has finished, and
            # - the display is :0.0
            # It's time for xset, eventually.
            xset -display :0.0 r rate 200 50
            logger "$0 -- auto repeat rate configured"
            ;;
    esac
}
main "$@"
