#!/usr/bin/env bash

WM=i3

function xrdb_merge() { [ ! -f $1 ] || xrdb -merge $1; }
function autolock()
{
    local o=(
        -detectsleep
        -notify 1800
        -notifier "xset dpms force off"
        -time 10
        -locker "slock sh -c 'xset dpms force off'"
    )
    xautolock "${o[@]}" &
}
function load_xinitd()
{
    [ -d /etc/X11/xinit/xinitrc.d ] || return 0

    local f
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ ! -x "$f" ] || source "$f"
    done
}
function configure_session()
{
    # systemctl --user after dwm hacky reload (i.e. from *console*, not terminal),
    # and when user@.service already started.
    export XDG_RUNTIME_DIR=/run/user/$UID
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus
}
function configure_screen_saver()
{
    xset s 600 600 # 10 min
}
function configure_keyboard()
{
    xset r rate 200 50
    xkbcomp ~/.xkeymap.xkb $DISPLAY
}
function configure_trackpad()
{
    xinput set-prop 'Synaptics TM3512-010' 'libinput Accel Speed' 0.5
}
function configure_mouse()
{
    xset mouse 6/1 3
}
function configure_pc_speaker()
{
    xset -b
}

function configure_outputs()
{
    if ! xrandr --listproviders | grep -F -q NVIDIA; then
        return 0
    fi

    # https://wiki.gentoo.org/wiki/NVIDIA/Optimus#xorg.conf
    xrandr --setprovideroutputsource NVIDIA-G0 Intel
    ~/assets/hotplug-monitor.sh
}

function main()
{
    configure_outputs

    xrdb_merge /etc/X11/xinit/.Xresources
    configure_screen_saver
    configure_keyboard
    configure_trackpad
    configure_mouse
    configure_pc_speaker
    xrdb_merge $HOME/.Xresources
    load_xinitd
    xbindkeys
    xrandr --dpi 144
    configure_session

    if [ ! "$WM" = awesome ] && [ ! "$WM" = i3 ]; then
        feh --no-fehbg --bg-scale ~/assets/wallpapers/bg.jpg
    fi

    if [ ! "$WM" = i3 ]; then
        autolock
        slock &
    else
        i3lock
    fi

    $WM
}
main "$@"
