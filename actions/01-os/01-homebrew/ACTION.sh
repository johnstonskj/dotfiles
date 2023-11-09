if [[ $ACTION = install && $OSSYS = macos ]] ; then
	run_command curl -fsSL -o $LOCAL_DOWNLOADS/brew-install.rb https://raw.githubusercontent.com/Homebrew/install/master/install
	run_command /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	remove_file $LOCAL_DOWNLOADS/brew-install.rb
fi

if [[ $ACTION = update && $OSSYS = macos ]] ; then
	run_command $INSTALLER $ACTION
    run_command $INSTALLER cleanup
    # and maybe ... $INSTALLER doctor
fi
