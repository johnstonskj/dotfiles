#! /usr/bin/env zsh

DOTFILEDIR=${0:a:h}
WORKDOTFILEDIR=$DOTFILEDIR/work-dotfiles
ACTIONDIR=$DOTFILEDIR/actions

source $ACTIONDIR/00/logging.zsh
source $ACTIONDIR/00/common.zsh

check_not_sudo 

decode_os_type

parse_action $*

run_actions
