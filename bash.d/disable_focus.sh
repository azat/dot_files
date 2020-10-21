# https://unix.stackexchange.com/questions/480052/how-do-i-detect-whether-my-terminal-has-focus-in-the-gui-from-a-shell-script/480138#480138
#
# On each focus event, you receive either \e[I (in) or \e[O (out) from the input stream.
# Which will trigger ^], which will show identities (or "E349: No identifier under cursor") in vim.
#
# But they were enabled by some reason, since after reset(1) they are disabled.
#
#   From https://stackoverflow.com/a/62156386/328260:
#
#     I encountered this problem when I would lose an ssh connection, so tmux
#     on the remote server that enabled FocusIn/FocusOut mode would not be able
#     to disable it. If I opened a vim on my local machine, vim would receive
#     those events. If the FocusIn/FocusOut mode is not the default for your
#     terminal, you can also disable it with:
#
# NOTE: disable for now, since that was a temporary issue
#
#echo -ne '\e[?1004l' # disable FocusIn/FocusOut
