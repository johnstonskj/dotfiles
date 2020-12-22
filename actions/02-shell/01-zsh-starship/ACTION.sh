if [[ $ACTION = (install|update) ]] ; then
	log-debug "+++ adding Starship prompt"
	install_package starship
fi

if [[ $ACTION = (install|update|link) ]] ; then
	link_file starship.toml $LOCAL_CONFIG/starship.toml
fi
