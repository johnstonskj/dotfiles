if [[ $ACTION = install ]] ; then
	log-debug "+++ installing homebrew package manager"
	if [[ $OSSYS = macos ]] ; then
	    if [ ! -d "/usr/local/Homebrew" ]; then
	 		run_command curl -fsSL -o $DOWNLOADS/brew-install.rb https://raw.githubusercontent.com/Homebrew/install/master/install
	 		run_command /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" 
	 		remove_file $DOWNLOADS/brew-install.rb
			run_command brew tap 'homebrew/services'
			run_command brew services
	    fi
	fi
fi

if [[ $ACTION = update ]] ; then
	log-debug "+++ updating package managers"
	run_command $INSTALLER $ACTION
	log-debug "+++ running package manager cleanup actions"
	if [[ $OSSYS = macos ]] ; then
	    run_command $INSTALLER cleanup
	    # and maybe ... $INSTALLER doctor
	else
	    run_command $INSTALLER autoremove
	fi
fi
