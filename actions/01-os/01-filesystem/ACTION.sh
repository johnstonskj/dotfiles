if [[ $OSSYS = macos ]] ; then
    run_command sudo mkdir /var/run/simonjo
    run_command sudo mkdir /opt/xdg

    # TOD: sudo these two
    link_file base-dirs.defaults /opt/xdg/base-dirs.defaults
    link_file user-dirs.defaults /opt/xdg/user-dirs.defaults

    link_file xdg-user-dir $LOCAL_BIN/xdg-user-dir
    link_file xdg-user-dirs-update $LOCAL_BIN/xdg-user-dirs-update
fi
