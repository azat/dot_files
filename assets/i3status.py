#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This script is a simple wrapper which prefixes each i3status line with custom
# information. It is a python reimplementation of:
# http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.pl
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.py
# In the 'bar' section.
#
# In its current version it will display the cpu frequency governor, but you
# are free to change it to display whatever you like, see the comment in the
# source code below.
#
# © 2012 Valentin Haenel <valentin.haenel@gmx.de>
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License (WTFPL), Version
# 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.

import sys
import json
from glob import glob
from subprocess import check_output as exec

def get_fan():
    with open(glob('/sys/class/hwmon/hwmon*/fan1_input')[0]) as f:
        rpm = int(f.read().strip())
    if not rpm:
        color = '#00ff00'
    else:
        color = '#ff0000'
    return {
        'color': color,
        'name': 'rpm',
        'full_text': f'{rpm}RPM',
    }

def get_governor():
    with open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor') as f:
        governor = f.read().strip()
    if governor == 'powersave':
        governor = 'pwrsave'
        color = '#00ff00'
    if governor == 'performance':
        governor = 'perf'
        color = '#ff0000'
    return {
        'color': color,
        'name': 'governor',
        'full_text': governor,
    }

def get_docker():
    # TODO: add Running/Stopped/Paused
    (containers, ) = map(int, exec(['docker', 'info', '-f', '{{ .Containers }}']).decode().strip().split(' '))
    if containers:
        color = '#0000ff'
    else:
        color = '#00ff00'
    return {
        'color': color,
        'name': 'docker',
        'full_text': f'D: {containers}',
    }

def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

if __name__ == '__main__':
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)
        # insert information into the start of the json, but could be anywhere
        # CHANGE THIS LINE TO INSERT SOMETHING ELSE
        j.insert(6, get_fan())
        j.insert(7, get_governor())
        j.insert(8, get_docker())
        # and echo back new encoded json
        print_line(prefix+json.dumps(j))
