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
        # delete all breakpoints
        gdb.execute("d")
        gdb.execute("break free")
        # loop iterations only in free()
        gdb.execute("continue")

        max = 1 << 24
        i = 0

        initial = self.memory()

        for i in range(max):
            try:
                mem = gdb.selected_frame().read_var("mem")
                current = self.mallocUsableSize(mem)
            except gdb.error:
                break

            bt = gdb.execute("bt", False, True)

            # 5 %
            if (current > initial*0.05):
                print "Current: %lu bytes, initial %lu bytes (%i iteration)" % (current, initial, i)
                print "Backtrace before current free():\n%s" % (bt)
                return

            if ((i % 100000) == 0):
                print "Iteration %i backtrace:\n%s" % (i, bt)

            gdb.execute("continue", False, True)

        print "Finished with %i iterations" % (i)
        print "Last backtrace:\n%s" % (bt)

    def memory(self):
        # VmSize:   111784 kB
        mem = gdb.execute("info proc status", False, True)
        return int(re.search("VmSize:\s*([0-9]*) kB", mem).group(1))*1024
    def mallocUsableSize(self, ptr):
        mem = gdb.execute("p malloc_usable_size(%lu)" % ptr, False, True)
        return int(re.search("= ([0-9]*)", mem).group(1))

leaking()

