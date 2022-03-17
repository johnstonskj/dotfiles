if [[ $ACTION = install ]] ; then
    log-debug "+++ installing alacrity"
	if [[ $OSSYS = macos ]] ; then
	    install_package_for macos -app alacrity
	else
	    run_command add-apt-repository ppa:mmstick76/alacritty
	    install_package_for linux alacrity
	fi

    link_file alacritty.yml $LOCAL_CONFIG/alacritty/alacritty.yml
    
	run_command mkdir -p ~/.zsh_functions
	run_command curl https://github.com/alacritty/alacritty/blob/master/extra/completions/_alacritty > ~/.zsh_functions/_alacrity

#	run_command curl https://github.com/alacritty/alacritty/blob/master/extra/alacritty.info > $LOCAL_DOWNLOADS/alacritty.info
#	run_command sudo tic -xe alacritty,alacritty-direct $LOCAL_DOWNLOADS/alacritty.info
#	remove_file $LOCAL_DOWNLOADS/alacritty.info
fi
