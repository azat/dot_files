#
# https://github.com/ellzey/dotfiles/blob/master/gdb/gdb_mutexinfo.py
#
# gdb plugin to print out mutex information on all threads
# who owns the lock, and who is attempting to obtain the lock

import gdb

class thread_holder:
    def __init__(self, thread):
        self.thread = thread

    def __enter__(self):
        self.save = gdb.selected_thread()
        self.thread.switch()

    def __exit__ (self, exc_type, exc_value, traceback):
        try:
            self.save.switch()
        except:
            pass
        return None

def print_thread (thr, owner):
    if thr == selected_thread:
        gdb.write("* \n"),
    else:
        gdb.write("  \n"),
    if owner:
        gdb.write("Owned by thread\n"),
    else:
        gdb.write("Thread\n"),
    (pid, lwp, tid) = thr.ptid
    gdb.write("%d  " % lwp)

class info_mutex(gdb.Command):
    def __init__ (self):
        gdb.Command.__init__ (self, "info mutex", gdb.COMMAND_NONE)

    def invoke (self, arg, from_tty):
        # Map a mutex ID to the LWP owning the mutex.
        owner = {}
        # Map an LWP id to a thread object.
        threads = {}
        # Map a mutex ID to a list of thread objects that are waiting
        # for the lock.
        mutexes = {}

        for inf in gdb.inferiors():
            for thr in inf.threads():
                id = thr.ptid[1]
                threads[id] = thr
                with thread_holder(thr):
                    frame = gdb.selected_frame()
                    lock_name = None
                    for n in range(5):
                        if frame is None:
                            break
                        fn_sym = frame.function()
                        if fn_sym is not None and (fn_sym.name == '__pthread_mutex_lock' or fn_sym.name == '__pthread_mutex_lock_full' or fn_sym.name == 'pthread_mutex_timedlock'):
                            m = frame.read_var ('mutex')
                            lock_name = long (m)
                            if lock_name not in owner:
                                owner[lock_name] = long (m['__data']['__owner'])
                                break
                        frame = frame.older()
                    if lock_name not in mutexes:
                        mutexes[lock_name] = []
                    mutexes[lock_name] += [thr]

        global selected_thread

        selected_thread = gdb.selected_thread()

        for id in mutexes.keys():
            if id is None:
                gdb.write("Threads not waiting for a lock:\n")
            else:
                gdb.write("Mutex 0x%x:\n" % id)
                print_thread (threads[owner[id]], True)
            for thr in mutexes[id]:
                print_thread (thr, False)
            gdb.write("\n")

info_mutex()
