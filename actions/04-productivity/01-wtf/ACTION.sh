if [[ $ACTION = (install|update) ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    install_package wfutil
    fi
    run_command mkdir -p $LOCAL_CONFIG/wtf
	link_file wtf-config.yml $LOCAL_CONFIG/wtf/config.yml
fi
