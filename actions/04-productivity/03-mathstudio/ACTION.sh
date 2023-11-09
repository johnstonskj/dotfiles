# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

if [[ $OSSYS = macos ]] ; then

    APP_ID=$(mas search MathStudio |grep MathStudio |cut -d " " -f4)

    if [[ $ACTION = install ]] ; then
        mas install $APP_ID
    fi

    link_aliases_file mathstudio
fi

