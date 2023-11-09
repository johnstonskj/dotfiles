make_dir $LOCAL_CONFIG/bat
link_file config $LOCAL_CONFIG/bat/config

make_dir $LOCAL_CONFIG/bat/syntaxes

if [[ $ACTION = (install|update) ]] ; then
	run_command bat cache --build
fi

link_aliases_file bat
link_env_file bat
