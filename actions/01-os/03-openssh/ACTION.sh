# OpenSSH included by default on Darwin

if [[ $OSSYS = linux && $ACTION = (install|update|uninstall) ]] ; then
	log-debug "+++ install openssh packages"
	local SSHDCONF=/etc/ssh/sshd_config
	install_package openssh-server

	if [[ $ACTION = install ]] ; then
	    log-debug "+++ setting openssh config"
	    run_command sudo mv $SSHDCONF $SSHDCONF.orig
	    run_command sudo cat $SSHDCONF.orig | sed 's/#Port 22/Port 1337/g' > $SSHDCONF
	    run_command sudo ufw allow 1337
	    run_command sudo service ssh restart
	fi
fi

link_env_file openssh
