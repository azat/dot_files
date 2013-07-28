#
# Bash functions
#

function get_base_name()
{
	local _path=${1/*\//}
	echo "${_path%.*}"
}

function get_path()
{
	# If don't have "/" at all
	if $(expr index "$1" / &>/dev/null); then
		echo "${1/%\/*/}"
	else
		echo "./"
	fi
}

make_file()
{
	local _bin_name="$(get_path "$1")/$(get_base_name "$1")"
	echo "Making '$1' to '$_bin_name'" >&2
	if [ ! -f "$_bin_name" ]; then
		gcc -ofast -std=c99 -o "$_bin_name" "$1"
	fi
	echo "$_bin_name"
}

# mk & cd
function mkcd() {
	[ -n "$1" ] && mkdir -p "$@" && cd "$1";
}

# Search commandlinefu.com from the command line using the API
function cmdfu() {
	curl "http://www.commandlinefu.com/commands/matching/$@/$(echo -n $@ | openssl base64)/plaintext";
}

# mini scp deploy
function scpdeploy() {
	if [ ! "$1" ] ; then
		echo "Usage scpdeploy SERVER_AND_PATH"
		return;
	fi

	cd .. && tar -czf $OLDPWD.tgz `basename $OLDPWD` && scp $OLDPWD.tgz $1 && cd -
}

# mini scp deploy
function scpmdeploy() {
	if [ ! "$1" ] ; then
		echo "Usage scpdeploy SERVER_AND_PATH"
		return;
	fi

	make clean && cd .. && export NOW=`basename $OLDPWD` && rm -f $NOW.tgz && tar -czf $NOW.tgz $NOW && scp $NOW.tgz $1 && cd -
}


# MS Word grep
# Using "antiword" package
function wgrep() {
	if [ $# -lt 2 ]; then
		echo "Usage: wgrep pattern file[ file ...]" > /dev/sderr
		return;
	fi

	WORD=$1

	i=0
	#for file in `ls *.doc | grep -v '^~'`; do
	for file in "$@"; do
		# pattern
		i=$[$i+1]
		if [ $i -eq 1 ]; then
			continue
		fi

		OLDIFS=$IFS
		IFS=""
		out=`antiword $file | grep -niH $WORD`
		if [ $? -eq 0 ]; then
			echo `echo $out | sed -e "s/\(standard input\)/$file/g"`
		fi
		IFS=$OLDIFS
	done
}

# Bak file/dir
# Usage `bak dir1 [ dir2]`
function bak() {
	if [ $# -lt 1 ]; then
		echo "Usage: bak file1[ file2 ...]" > /dev/stderr
	fi

	i=0
	for path in "$@"; do
		i=$[$i+1]
		file=`basename $path`
		len=`echo "${#path}-${#file}" | bc`
		dir=${path:0:len}
		if [ "x$dir" == "x" ]; then
			dir="./"
		fi

		mv "$path" "$dir.$file.bak"
	done
}

# Unbak file/dir
# Usage `unbak dir1 [ dir2]`
function unbak() {
	if [ $# -lt 1 ]; then
		echo "Usage: unbak file1[ file2 ...]" > /dev/stderr
	fi

	i=0
	for path in "$@"; do
		i=$[$i+1]

		# Replace './'
		path=`echo $path | sed 's/^\.\/|\/\.\///g'`

		replace=`echo $path | sed 's/^\.\(.*\)\.bak$/\1/'`
		if [ "$path" == "$replace" ] ; then
			# try to change src file
			file=`basename $path`
			len=`echo "${#path}-${#file}" | bc`
			dir=${path:0:len}
			if [ "x$dir" == "x" ]; then
				dir="./"
			fi
			new_file="$dir/.$file.bak"

			if [ -f $new_file ] ; then
				path=$new_file
			else
				echo "$file is not backup-ed" > /dev/stderr
				continue
			fi
		fi

		mv "$path" "$replace"
	done
}

