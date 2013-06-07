#
# Run git from gdb
#
# Command:
# git ...
#

import gdb
from subprocess import call

class git(gdb.Command):
    def __init__(self):
        gdb.Command.__init__ (self, "git", gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_tty):
        call("git " + arg, shell=True)

git()
