if [[ -n $BREW ]] ; then
    install_package_for macos -app kitty
else
    run_command "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
fi

link_file kitty.conf $LOCAL_CONFIG/kitty/kitty.conf

link_file themes $LOCAL_CONFIG/kitty/themes
