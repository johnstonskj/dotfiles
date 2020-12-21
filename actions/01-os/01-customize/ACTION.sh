if [[ $OSSYS = macos && $ACTION = install ]] ; then
	log-debug "+++ writing common defaults"
	run_command defaults write com.apple.dashboard devmode YES
	run_command defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
	run_command defaults write com.apple.Dock showhidden -bool YES
fi
