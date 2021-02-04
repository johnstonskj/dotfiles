install_package gpg
install_package_for linux pinentry-gnome3
install_package_for macos pinentry-mac

GPG_HOME=$HOME/.gnupg

link_file gpg.conf $GPG_HOME/gpg.conf

if [[ $OPSYS = linux ]] ; then
	link_file gpg-agent-linux.conf $GPG_HOME/gpg-agent.conf
if [[ $OPSYS = macos ]] ; then
	link_file gpg-agent-mac.conf $GPG_HOME/gpg-agent.conf
fi

if [[ $ACTION = install ]] ; then
	if [ ! -d $GPG_HOME ] ; then
	    log-info "++ GPG initialization..."
	    run_command gpg --list-keys
	fi
fi
