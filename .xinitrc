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
    xset r rate 200 35
    xkbcomp ~/.xkeymap.xkb $DISPLAY
}

function main()
{
    xrdb_merge /etc/X11/xinit/.Xresources
    configure_screen_saver
    configure_keyboard
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
