install_package_for macos sublime-text
install_package_for macos sublime-merge

if [[ $ACTION = (install|update|link) ]] ; then
    run_command ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl $LOCAL_BIN/subl
fi
