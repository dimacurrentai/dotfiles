#!/bin/bash
#
# This "script" is meant to be copy-pasted into a fresh Ubuntu.
# Testing under WSL, because why not?

sudo apt-get update

ALL_APT_PACKAGES="""
git zsh vim curl wget jq screen
sudo build-essential cmake
python3 python3-dev
golang nodejs
default-jdk gradle
libncurses-dev
libncurses5-dev
podman
tree
x11-apps
libncurses-dev
gnuplot plotutils
openssh-server
gnuplot
meld
qrencode
python3-pip
python3-colorama
lcov
htop
inetutils-tools
net-tools
cloc
clang-format
android-sdk
sdkmanager
"""

time sudo apt-get install -y $ALL_APT_PACKAGES

#echo zsh | chsh
#
#git clone https://github.com/dkorolev/dotfiles ~/.dotfiles
#cp ~/.dotfiles/.zshrc /home/dev/
#cp ~/.dotfiles/.vimrc /home/dev/
#cp ~/.dotfiles/.inputrc /home/dev/
#cp ~/.dotfiles/.screenrc /home/dev/
#
#git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/Valloric/YouCompleteMe ~/.vim/pack/plugins/opt/YouCompleteMe
#(cd ~/.vim/pack/plugins/opt/YouCompleteMe; ./install.py --all)
