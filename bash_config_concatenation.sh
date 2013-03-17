#!/bin/sh

SERVER_VERSION="$1"
SELF=${0%/*}
FILES="$SELF/bash.bashrc \
	$SELF/bash_functions"

if [ "$SERVER_VERSION" ]; then
	FILES="$FILES /etc/bash_completion.d/git"
fi

for FILE in $(ls -d $SELF/bash.d/* | fgrep -v autojump.sh | fgrep -v remark.sh); do
	FILES="$FILES $FILE"
done

echo "#"
echo "# Generated at $(date)"
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
		cat $FILE | sed 's/currentUserColor=$BRed/currentUserColor=$URed/' | sed 's/currentUserColor=$BGreen/currentUserColor=$UGreen/'
	else
		cat $FILE
	fi

	echo
	echo "# }}}"
done

