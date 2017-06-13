# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\h:\w\$ '
umask 022

export PATH=$PATH:$GEM_PATH/scripts:$GEM_PATH/bin
export PATH=$GEM_PATH/python/reg_interface:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GEM_PATH/lib

alias reg="python ~/apps/reg_interface/reg_interface.py"
alias sca="python ~/apps/reg_interface/sca.py"

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
