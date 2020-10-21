#!/usr/bin/env python

"""
Monitor systemd journal activity, and execute --cmd if --pattern matched
"""

import argparse
import os, sys
import re
import logging
import subprocess
import select # TODO: libevent wrapper
from systemd import journal

log = logging.getLogger()

def execute(cmd):
    log.info("exec={}".format(cmd))
    subprocess.check_call(cmd, shell=True)
def parse_opts():
    p = argparse.ArgumentParser()
    p.add_argument('--pattern', required=True, action='append')
    p.add_argument('--cmd', required=True)
    p.add_argument('--loop', default=True, action='store_true')
    p.add_argument('-v', '--verbose', dest='verbose_count', action='count', default=0)
    return p.parse_args()
def main():
    opts = parse_opts()

    patterns = [ re.compile(p) for p in opts.pattern ]
    base     = os.path.basename(os.path.realpath(__file__))

    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG,
        format='%(filename)s: %(name)s (%(levelname)s): %(message)s')
    # -v -- info only
    # -vv -- info+debug
    # ...
    log.setLevel(max(3 - opts.verbose_count, 0) * 10)

    j = journal.Reader()
    j.this_boot()
    j.this_machine()
    j.seek_tail()
    # https://bugzilla.redhat.com/show_bug.cgi?id=979487 workaround
    j.get_next(-1)

    running = True
    p = select.epoll()
    p.register(j, j.get_events())
    while p.poll() and running:
        entry = j.get_next()
        if not 'MESSAGE' in entry:
            j.wait()
            continue
        msg = entry['MESSAGE']
        # avoid recursion when it is runned under systemd
        if base in msg:
            j.wait()
            continue
        log.debug("msg={}".format(msg))
        for pattern in patterns:
            if re.match(pattern, msg):
                execute(opts.cmd)
                if not opts.loop:
                    running = False
                    break
        j.wait()
    logging.shutdown()

if __name__ == "__main__":
    main()
