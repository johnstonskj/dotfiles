install_package -app vcv-rack

if [[ $OSSYS = macos && $ACTION = install ]] ; then
	xattr -d com.apple.quarantine /Applications/Rack/Rack.app
fi