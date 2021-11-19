install_package ipfs
link_env_file ipfs

if [[ $ACTION = install ]] ; then
    run_command ipfs init

    if [[ $OPSYS = macos ]] ; then
	run_command brew services start ipfs
    fi
fi

