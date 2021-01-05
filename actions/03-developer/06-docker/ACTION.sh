if [[ $ACTION = (install|update) ]] ; then
	if [[ $OSSYS = macos ]] ; then
		install_package_for macos -app docker
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
fi

if [[ $ACTION = update ]] ; then
	log-debug "+++ pulling Docker images from $CURR_ACTION/docker-images"
	source "$CURR_ACTION/docker-env"
	docker run -d
	while IFS= read -r line; do
		log-debug "+++ +++ docker image $line"
	    run_command docker pull $line
	done < "$CURR_ACTION/docker-images"
fi

link_env_file docker
