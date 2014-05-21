#
# Helpers for linux kernel
#
# Using "monitor" command
# (for this you need kdb support)
#
# Available commands:
# - info linux per_cpu_by_name VAR_NAME
#

import gdb

class InfoLinux(gdb.Command):
    def __init__(self):
        gdb.Command.__init__ (self, "info linux", gdb.COMMAND_OBSCURE)

    def invoke(self, args, from_tty):
        methodName = "command_" + args.partition(" ")[0]
        self.callMethod(methodName, args)

    def command_per_cpu_by_name(self, args):
        variableName = args.partition(" ")[2]
        variableNameRef = gdb.parse_and_eval(variableName)
        variablePtr = variableNameRef.address

        lines = gdb.execute("monitor per_cpu 0x%lx" % variablePtr, False, True).split("\n")
        for line in lines:
            if not line.strip():
                continue
            parts = line.strip().split(" ")
            absolutePtr = int("0x" + parts[2].strip(), 16)
            gdb.write("0x%lx\n" % absolutePtr)


    #
    # Helpers
    #
    def humanSizeOf(self, num):
        for x in ['bytes','KiB','MiB','GiB','TiB']:
            if num < 1024.0:
                return "%3.1f %s" % (num, x)
            num /= 1024.0

    def callMethod(self, name, args):
        getattr(self, name)(args)

InfoLinux()

