if [[ $OSSYS = macos && $ACTION = install ]] ; then
    xcode-select --install
    sudo xcode-select --switch /Applications/Xcode.app
fi