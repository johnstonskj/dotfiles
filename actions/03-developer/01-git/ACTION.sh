if [[ $ACTION = (install|update) ]] ; then
	install_package git git-lfs
	install_package_for linux git-hub
	# maybe one day - https://github.com/sickill/git-dude
fi

if [[ $ACTION = (install|update|link) ]] ; then
	link_file dot-gitconfig $HOME/.gitconfig
	link_file dot-gitignore_global $HOME/.gitignore_global
	link_file git-tag-delete $LOCAL_BIN/git-tag-delete
	link_file git-tag-replace $LOCAL_BIN/git-tag-replace
fi
