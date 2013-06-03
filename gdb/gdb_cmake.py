#
# Run cmake from gdb
#
# Command:
# cmake
#

import gdb
from subprocess import call

class cmake(gdb.Command):
    def __init__(self):
        gdb.Command.__init__ (self, "cmake", gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_tty):
        call("cmake " + arg, shell=True)

cmake()
