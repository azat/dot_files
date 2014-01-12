#
# TODO: use class instead of command
# requires ./gdb_memory.py
#
# Try to investigate memory leaks,
# run leaking when youu program must _free_ some mem.
# (was written to investigate leaking in tmux)
#

import gdb
import re

class leaking(gdb.Command):
    def __init__(self):
        gdb.Command.__init__ (self, "leaking", gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_tty):
        gdb.execute("break free")

        max = 1 << 24
        i = 0
        prev = self.memory()
        print "Start: %lu bytes" % (prev)

        while ++i < max:
            current = self.memory()
            if ((prev - current) > prev * 0.1):
                print "Current: %lu bytes, was %lu bytes (%i iteration)" % (current, prev, i)
                print "Backtrace before current free():\n%s" % (prevBt)
                break

            prevBt = gdb.execute("bt", False, True)
            if ((i % 100000) == 0):
                print "Iteration %i backtrace:\n%s" % (i, prevBt)

            gdb.execute("continue", False, True)

    def memory(self):
        mem = gdb.execute("info memory", False, True)
        return int(re.search("\(([0-9]*) bytes\)", mem).group(1))

leaking()

