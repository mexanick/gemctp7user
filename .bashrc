# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\h:\w\$ '
#export SHELL=~/apps/bash
umask 022

#alias python=/mnt/persistent/texas/apps/python-2.7.5/bin/python2.7
#alias vim=/mnt/persistent/texas/apps/vim/bin/vim
#alias git=/mnt/persistent/texas/apps/git/bin/git
alias reg="python ~/apps/reg_interface/reg_interface.py"
alias sca="python ~/apps/reg_interface/sca.py"

#export LD_LIBRARY_PATH=~/apps/python-2.7.5/lib/:~/shared_libs/:/usr/lib/
#export VIMRUNTIME=~/.vim/
# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
#eval `dircolors`
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
