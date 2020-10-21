#!/usr/bin/env bash

opts=(
    --tiling
    --image ~/assets/wallpapers/bg.png
)
xset dpms force off
i3lock "${opts[@]}" "$@"
