install_package gpg
install_package_for macos pinentry-mac

GPG_HOME=$HOME/.gnupg

link_file gpg-agent.conf $GPG_HOME/gpg-agent.conf
link_file gpg.conf $GPG_HOME/gpg.conf

if [[ $ACTION = install ]] ; then
	if [ ! -d $GPG_HOME ] ; then
	    log-info "++ GPG initialization..."
	    run_command gpg --list-keys
	fi
fi
