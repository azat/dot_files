#!/usr/bin/env bash

#
# Non-universal vim config concatenator.
#

SELF=${0%/*}

START_FROM="$SELF/vim/vimrc"
SOURCE_PATTERN="source "
ADDITIONAL_FILES=$(grep "$SOURCE_PATTERN" $START_FROM | awk '{print $2}')

function printHeader()
{
	echo
	echo "\" Begining of $FILE"
	echo "\" {{{"
	echo
}

function printFooter()
{
	echo
	echo "\" }}}"
}

echo "\""
echo "\" Generated at $(date)"
echo "\" From https://github.com/azat/dot_files"
echo "\""

# vimrc
printHeader
cat $START_FROM | grep -v $SOURCE_PATTERN
printFooter
echo

for FILE in $(echo $ADDITIONAL_FILES); do
	if [ ! -f $FILE ]; then
		continue;
	fi

	echo
	echo "\" Begining of $FILE"
	echo "\" {{{"
	echo

	cat $FILE

	echo
	echo "\" }}}"
done
