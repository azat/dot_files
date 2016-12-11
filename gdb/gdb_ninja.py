#
# Why only "make" works inside gdb?
#
# Command:
# ninja ...
#

import gdb
from subprocess import call

class ninja(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, "ninja", gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_tty):
        call("ninja " + arg, shell=True)
        for o in gdb.objfiles():
            print("Reload %s" % (o.filename))
            self.reload(o.filename)

    def reload(self, filename):
        gdb.execute("symbol-file %s" % (filename))

ninja()
