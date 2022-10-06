if [[ $OSSYS = macos && $ACTION = install ]] ; then
    xcode-select --install
    if [[ -d /Applications/Xcode.app ]]; then
        sudo xcode-select --switch /Applications/Xcode.app
    fi
fi

XCODE_THEMES=$(xcode-select -p)/UserData/FontAndColorThemes
if [[ -d $XCODE_THEMES ]]; then
    curl https://raw.githubusercontent.com/stackia/solarized-xcode/master/Solarized%20Dark.xccolortheme >"$XCODE_THEMES/Solarized Dark.xcolortheme"
    curl https://raw.githubusercontent.com/stackia/solarized-xcode/master/Solarized%20Light.xccolortheme >"$XCODE_THEMES/Solarized Light.xcolortheme"
fi

link_env_file xcode-env
