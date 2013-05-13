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

function handleFile()
{
	printHeader "$1"

	FUNC_NAME="funciton LoadFile_$(echo "$1" | tr '/.' '_')"
	echo "function! $FUNC_NAME()"
	while read line; do
		# TODO: use bash build-in commands
		if ! $(echo "$line" | fgrep -v '"' | egrep -q "^[\t ]*source "); then
			echo $line
			continue
		fi

		INCLUDE="$(echo $line | awk '{print $NF}')"
		if [ ! -f "$INCLUDE" ]; then
			echo "\" GENERATOR: File '$INCLUDE' not found."
			continue
		fi
		echo "\" GENERATOR: Inlining '$INCLUDE'"
		handleFile "$INCLUDE"
	done < "$1"
	echo "endfunction"
	echo "call $FUNC_NAME()"

	printFooter "$1"
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
