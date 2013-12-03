#!/usr/bin/env bash

echo "\""
echo "\" Generated at $(date)"
echo "\" Version: $(git describe 2>/dev/null || git sha1)"
echo "\" From https://github.com/azat/dot_files"
echo "\""

sed 's/\/etc\/vim/~\/.vim/g' ./vim/vimrc

