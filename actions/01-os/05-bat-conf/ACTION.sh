make_dir $LOCAL_CONFIG/bat
link_file config $LOCAL_CONFIG/bat/config

if [[ $ACTION = (install|update) ]] ; then
	run_command bat cache --build
fi

link_env_file bat
