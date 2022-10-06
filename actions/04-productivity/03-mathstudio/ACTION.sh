if [[ $OSSYS = macos ]] ; then

    APP_ID=$(mas search MathStudio |grep MathStudio |cut -d " " -f4)

    if [[ $ACTION = install ]] ; then
        mas install $APP_ID
    fi

    link_env_file mathstudio
fi

