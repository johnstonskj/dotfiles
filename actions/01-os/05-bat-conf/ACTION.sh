
run_command mkdir -p $LOCAL_CONFIG/bat
link_file config $LOCAL_CONFIG/bat/config

if [[ $ACTION = update ]] ; then
	run_command bat cache --build
fi