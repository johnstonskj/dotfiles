install_package gpg

if [[ $ACTION = (install|update) ]] ; then
	if [ ! -d $HOME/.gnupg ] ; then
	    log-info "++ GPG initialization..."
	    run_command gpg --list-keys
	fi
fi
