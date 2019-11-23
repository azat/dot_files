function load_files()
{
	local f
	for f; do
		if load_file "$f"; then
			break
		fi
	done
	return 0
}
function load_file()
{
	local f="$1"
	if [ -f "$f" ]; then
		source "$f"
		return 0
	fi
	return 1
}
load_files \
	/etc/profile.d/autojump.sh \
	/usr/share/autojump/autojump.sh \
	/usr/share/autojump/autojump.bash
