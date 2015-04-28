
#
# TODO: maybe use rename pane?
#

settitle() {
	printf "\033k$1\033\\"
}

ssh() {
	if [ -z "$TMUX" ] || [ ! -t 0 ] || [ ! -t 1 ] || [ ! -t 2 ]; then
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

tmuxcapture()
{
	local pattern=${1:-"tmux.%n.%w.%p"}
	local start=${2:-"-1000000000"}

	local n w p _ name
	while read w n _; do
		w=${w/:}
		for p in $(tmux list-pane -t "$w" | cut -d: -f1); do
			echo "Dumping window $n:$w:$p"

			name="$pattern"
			name=${name/\%n/$n}
			name=${name/\%w/$w}
			name=${name/\%p/$p}

			tmux -q capture-pane -t "${w}.${p}" -p -S "$start" >| "$name"
		done
	done < <(tmux list-windows)
}
