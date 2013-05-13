#!/usr/bin/env bash

#
# Non-universal vim config concatenator.
#

SELF=${0%/*}

START_FROM="$SELF/vim/vimrc"
SOURCE_PATTERN="source "

function printHeader()
{
	echo
	echo "\" Begining of $1"
	echo "\" {{{"
	echo
}

function printFooter()
{
	echo
	echo "\" }}}"
}

#
# @arg fName
#
function handleFile()
{
	FILE=$(readlink -f "$1")

	printHeader "$FILE"

	while IFS=$'\n' read line; do
		# TODO: use bash build-in commands
		if ! $(echo "$line" | fgrep -v '"' | egrep -q "^[\t ]*source "); then
			echo "$line"
			continue
		fi

		ORIG_INCLUDE="$(echo $line | awk '{print $NF}')"
		ESCAPED_ORIG_INCLUDE="${ORIG_INCLUDE//\//\\/}"
		INCLUDE="$(readlink -f "$ORIG_INCLUDE")"
		ESCAPED_INCLUDE="${INCLUDE//\//\\/}"
		# Resolve symlinks
		line=$(echo $line | sed "s/$ESCAPED_ORIG_INCLUDE/$ESCAPED_INCLUDE/")

		# Not found, maybe it will under condititon, so leave line
		if [ ! -f "$INCLUDE" ]; then
			echo "\" GENERATOR: Doesn't exist '$INCLUDE'"
			echo "$line"
			continue
		fi

		# Don't include scripts from "taglist"
		# I have number of errors if I inline it.
		if $( echo "$INCLUDE" | grep -q "taglist.vim$" ); then
			echo "\" GENERATOR: Skip '$INCLUDE'"
			echo "$line"
			continue
		fi

		echo "\" GENERATOR: Inlining '$INCLUDE'"
		handleFile "$INCLUDE"
	done < "$FILE"

	printFooter "$FILE"
}

function printMainHeader()
{
	echo "\""
	echo "\" Generated at $(date)"
	echo "\" From https://github.com/azat/dot_files"
	echo "\""
}

# vimrc
printMainHeader
handleFile "$START_FROM"
