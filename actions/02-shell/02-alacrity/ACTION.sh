if [[ $ACTION = install ]] ; then
    log-debug "+++ installing alacrity"
	if [[ $OSSYS = macos ]] ; then
	    install_package_for macos -app alacrity
	else
	    run_command add-apt-repository ppa:mmstick76/alacritty
	    install_package_for linux alacrity
	fi
	run_command curl https://github.com/jwilm/alacritty/blob/master/extra/alacritty.man > $DOWNLOADS/alacrity.man
	run_command sudo mkdir -p /usr/local/share/man/man1
	run_command gzip -c $DOWNLOADS/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
	run_command rm $DOWNLOADS/alacritty.man

	run_command mkdir -p ~/.zsh_functions
	run_command curl https://github.com/jwilm/alacritty/blob/master/extra/completions/_alacritty > ~/.zsh_functions/_alacrity

	run_command curl https://github.com/jwilm/alacritty/blob/master/extra/alacritty.info > $DOWNLOADS/alacritty.info
	run_command sudo tic -xe alacritty,alacritty-direct $DOWNLOADS/alacritty.info
	run_command rm $DOWNLOADS/alacritty.info
fi
