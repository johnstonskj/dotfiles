if [[ $OSSYS = macos && $ACTION = install ]] ; then
	log-debug "+++ writing common defaults"
	run_command defaults write com.apple.dashboard devmode YES
    run_command defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    run_command defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
	run_command defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
    run_command defaults write com.apple.finder AppleShowAllFiles true
    run_command defaults write com.apple.finder ShowStatusBar -bool true
    run_command defaults write com.apple.finder NewWindowTarget -string "PfLo" && \
                defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"
	run_command defaults write com.apple.Dock showhidden -bool YES
    run_command defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
    run_command defaults -currentHost write -globalDomain AppleFontSmoothing -int 2
    run_command chflags hidden ~/Library
fi
