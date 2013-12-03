#!/usr/bin/env bash

SELF=${0%/*}

cd ~/
mkdir -p .vim/bundle/vundle
git clone https://github.com/gmarik/vundle.git .vim/bundle/vundle

