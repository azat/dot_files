
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

	# Non-interactive shell, will spawned on remote,
	# in this case settitle will just print headers
	# with command output, which is bad
	last="${@: -1}"
	nextToLast="${@: -2:1}"
	if [[ -n "$last" ]] && [[ ! "$last" =~ ^- ]] &&
		[[ -n "$nextToLast" ]] && [[ ! "$nextToLast" =~ ^- ]] && [[ ! "$nextToLast" =~ bash$ ]]; then
		command ssh "$@"
		return
	fi

	server="$last"
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

