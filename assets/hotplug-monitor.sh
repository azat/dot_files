#!/usr/bin/env bash

# DESCRIPTION:
#   This script should be runned by udev, i.e.:
#     $ cat > /etc/udev/rules.d/90-monitor.rules
#     ACTION=="change", SUBSYSTEM=="drm", RUN+="/bin/flock -n /tmp/monitor.udev.lock /home/azat/assets/hotplug-monitor.sh"
#
# BUGS:
#   But from time-to-time (from kernel-to-kernel) there is no drm/change event
#   on monitor disconnect, so to fix this you should run "xrandr" manually by
#   yourself. I guess that there is way more appropriate solution, which I do
#   not know about.
#
# POSSIBLE ISSUES:
# - No eDP after suspend/resume, when laptop is connected to the dock stations.
#
#   And this leads to after first press on power button on dock station laptop
#   resumes turning on external screen but by some reason goes again to
#   suspend, after power button pressed for the second time there is eDP-1 and
#   evertyhing resumes correctly.
#
#   But this does not happens all the time, it was all previous day, but today
#   everything works fine. Huh.
#
#   According to [1] next command can help:
#     echo detect > /sys/class/drm/card0-eDP-1/status
#
#   [1]: https://bugs.freedesktop.org/show_bug.cgi?id=103819 (no eDP after
#
# TODO:
#   Use sysfs rather then executing xrandr(1) every single time:
#   /sys/class/drm/card0-$1

export DISPLAY=:0
export XAUTHORITY=~azat/.Xauthority

function log() { logger "$(basename "$0"): $*"; }

function put()
{
    local out=$1 neighbor=$2
    shift 2

    xrandr --output "$out" --auto --above "$neighbor"
    log "Turning on -- $out (above $neighbor)"
}
function disconnect()
{
    local out=$1 && shift
    xrandr --output "$out" --off
    log "Turning off -- $out"
}

function is_connected() { xrandr | grep "^$1 connected" &> /dev/null; }

function toggle()
{
    local out=$1 neighbor=$2
    shift 2

    if is_connected "$out"; then
        put "$out" "$neighbor"
        return 0
    else
        disconnect "$out"
        return 1
    fi
}

function main()
{
    local laptop=eDP-1 master
    local neighbor=$laptop

    local displays=(
        HDMI-1
        HDMI-2
        DP-1
        DP-2

        # lenovo thunderbolt dock station
        DP-1-1
        DP-1-2
        DP-1-3
    )

    for display in "${displays[@]}"; do
        toggle $display $neighbor && {
            [[ -n $master ]] || master=$display
            neighbor=$display
        }
    done

    ~azat/.fehbg
}
main "$@"
