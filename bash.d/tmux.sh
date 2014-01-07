
#
# TODO: maybe use rename pane?
#

settitle() {
	printf "\033k$1\033\\"
}

ssh() {
	# Non in tmux
	if [ -z "$TMUX" ]; then
		command ssh "$@"
		return
	fi

	server="${@: -1}"
	settitle "$server"
	command ssh "$@"
	settitle "bash"
}

# $1 - session:windowNum
tmuxcatwindow()
{
	session_window="$1"
	start=${2:-"-1000000000"}
	[ -n "$session_window" ] || return
	(for i in $(tmux list-pane -t "$session_window" | awk -F: '{print $1}'); do tmux -q capture-pane -t "$session_window".$i -p -S "$start"; done)
}

