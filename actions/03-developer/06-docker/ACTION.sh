if [[ $ACTION = (install|update) ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    log-debug "+++ installing Docker desktop (from disk image)"
	    run_command curl -o $LOCAL_DOWNLOADS/Docker.dmg "https://download.docker.com/mac/stable/Docker.dmg"
	    run_command open $LOCAL_DOWNLOADS/Docker.dmg
	    log-debug "!!! leaving $LOCAL_DOWNLOADS/Docker.dmg"
	else
	    log-debug "+++ installing Docker CLI"
	    install_package apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	    if [[ $ACTION = install ]] ; then
			run_command curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
			run_command sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
			update_package_manager
	    fi
	    install_package docker-ce docker-ce-cli containerd.io
	    if [[ $ACTION = install ]] ; then
			log-debug "+++ updating Docker permissions"
			run_command sudo groupadd docker
			run_command sudo usermod -aG docker $USER
			if [ -e "$HOME/.docker" ] ; then
			    run_command sudo chown "$USER":"$USER" "$HOME/.docker" -R
			    run_command sudo chmod g+rwx "$HOME/.docker" -R
			fi
			run_command sudo systemctl enable docker
	    fi
	fi
	log-debug "+++ pulling Docker images from $DOTFILEDIR/docker-images"
	while IFS= read -r line; do
		log-debug "+++ +++ docker image $line"
	    run_command docker pull $line
	done < "$DOTFILEDIR/docker-images"
fi

if [[ $ACTION = install ]] ; then
	echo_instruction "docker run hello-world"
fi
