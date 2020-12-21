############################################################################
# Work delegated configuration
############################################################################

if [[ $ACTION = install ]] ; then
    if ping -c1 git.amazon.com &> /dev/null ; then
	log-info "Bootstrap work environment support"
	log-debug "+++ cloning ssh://git.amazon.com/pkg/SimonjoDotFiles"
	pushd $DOTFILEDIR
	run_command git clone ssh://git.amazon.com/pkg/SimonjoDotFiles $WORKDOTFILEDIR
	popd
    fi
fi

if [ -d "$WORKDOTFILEDIR" ] ; then
    log-info "Work related installs..."
    source "$WORKDOTFILEDIR/work-setup.zsh"
fi
