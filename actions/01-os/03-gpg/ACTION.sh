if [[ $ACTION = (install|upgrade) ]] ; then
	install_package gpg
	if [ ! -d $HOME/.gnupg ] ; then
	    log-info "++ GPG initialization..."
	    run_command gpg --list-keys
	fi
fi
