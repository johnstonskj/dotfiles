# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
############################################################################
# Flutter and Dart
############################################################################

install_package flutter

if [[ "${OSTYPE}" == "darwin"* ]]; then

    if [[ "${ARCHFLAGS}" =~ "arm64$" ]]; then
        echo "sudo softwareupdate --install-rosetta --agree-to-license"
    fi

    echo "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "sudo xcodebuild -runFirstLaunch"
    echo "sudo xcodebuild -license"

    echo "xcodebuild -downloadPlatform iOS"
    echo "open -a Simulator"
fi

if [[ $ACTION = (update) ]] ; then
	run_command flutter doctor
	run_command flutter precache
fi

if [[ $ACTION = (install|update) ]] ; then
	run_command ./makeenv > $LOCAL_CONFIG/dart/env
fi

link_file tool_state $LOCAL_CONFIG/dart/tool_state
