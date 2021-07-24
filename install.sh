#!/bin/sh

install_path=$HOME/.local/bin
mkdir -p $install_path
export PATH=$install_path:$PATH

ln -s /R/score.R $HOME/.local/bin

