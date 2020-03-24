#!/usr/bin/env bash

SERVER_VERSION="$1"
SELF=${0%/*}
FILES="$SELF/bash.bashrc"

#add git prompt
if [ "$SERVER_VERSION" ]; then
	if [ -f /usr/lib/git-core/git-sh-prompt ]; then
		FILES+=" /usr/lib/git-core/git-sh-prompt"
	elif [ -f /usr/share/git/completion/git-prompt.sh ]; then
		FILES+=" /usr/share/git/completion/git-prompt.sh"
	elif [ -f /usr/share/git/completion/git-prompt.sh ]; then
		FILES+=" /usr/share/git/git-prompt.sh"
	else
		echo "No git prompt" >&2
	fi
fi

for FILE in $SELF/bash.d/*.sh; do
	if [[ $FILE =~ (autojump|remark).sh ]]; then
		continue
	fi

	FILES+=" $FILE"
done

echo "#"
echo "# Generated at $(date)"
echo "# Version: $(git describe 2>/dev/null || git sha1)"
echo "# From https://github.com/azat/dot_files"
echo "#"
echo

for FILE in $(echo $FILES); do
	echo
	echo "# Begining of $FILE"
	echo "# {{{"
	echo

	if [ "$SERVER_VERSION" ]; then
		# Replace colors of user name in prompt to underlined
		cat $FILE | \
			sed 's/currentUserColor=$BRed/currentUserColor=$URed/' | \
			sed 's/currentUserColor=$BGreen/currentUserColor=$UGreen/'
	else
		cat $FILE
	fi

	echo
	echo "# }}}"
done

