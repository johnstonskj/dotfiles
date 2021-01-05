install_package starship

if [[ $ACTION = (install|update|link) ]] ; then
	link_file starship.toml $LOCAL_CONFIG/starship.toml
fi
