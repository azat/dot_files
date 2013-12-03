
#
# TODO: maybe use rename pane?
#

settitle() {
	printf "\033k$1\033\\"
}

ssh() {
	if [ -e "$TMUX" ]; then
		command ssh "$@"
		return
	fi

	server="${@: -1}"
	settitle "$server"
	command ssh "$@"
	settitle "bash"
}

