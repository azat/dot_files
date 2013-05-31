#
# Parse "info files" and print used memory
#

import gdb

class info_memory(gdb.Command):
    def __init__(self):
        gdb.Command.__init__ (self, "info memory", gdb.COMMAND_NONE)

    def invoke(self, arg, from_tty):
        memory = 0

        lines = gdb.execute("info files", False, True).split("\n")
        for line in lines:
            if 'load' in line:
                parts = line.split(" ")
                start = int(parts[0].strip(), 16)
                end = int(parts[2].strip(), 16)

                memory += (end - start)

        print "Memory: %s (%lu bytes)" % (self.sizeof_fmt(memory), memory)

    def sizeof_fmt(self, num):
        for x in ['bytes','KiB','MiB','GiB','TiB']:
            if num < 1024.0:
                return "%3.1f %s" % (num, x)
            num /= 1024.0

info_memory()
