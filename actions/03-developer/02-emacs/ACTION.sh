# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

EMACS_CONF=$HOME/.emacs.d

if [[ $OPSYS = macos && $ACTION = install ]] ; then
    run_command brew tap d12frosted/emacs-plus
    run_command brew install emacs-plus --with-dbus
    run_command ln -s /opt/homebrew/opt/emacs-plus@28/Emacs.app /Applications

    run_command brew install cask --ignore-dependencies
fi

install_package_for linux emacs-nox elpa-racket-mode
install_package aspell cmake

link_env_file emacs

if [[ $ACTION = (install|update|link) ]] ; then

    run_command git submodule init
    run_command git submodule update

    make_dir $EMACS_CONF/lib
	link_file emacs-init/init.el $EMACS_CONF/init.el
	link_file emacs-init/custom.el $EMACS_CONF/custom.el
    link_file emacs-init/init_zsh.sh $EMACS_CONF/init_zsh.sh

    link_file emacs-init/lib $EMACS_CONF/lib
    link_file emacs-init/org-init $EMACS_CONF/org-init

    if [[ $OPSYS = macos ]] ; then
        link_file emacs-server.plist ~/Library/LaunchAgents/emacs-server.plist
        log-info "launchctl load -w ~/Library/LaunchAgents/emacs-server.plist"
    fi

elif [[ $ACTION = uninstall ]] ; then

	remove_file $EMACS_CONF/init.el
	remove_file $EMACS_CONF/init_zsh.sh

    remove_file $EMACS_CONF/lib
    remove_file $EMACS_CONF/org-init

    if [[ $OPSYS = macos ]] ; then
        remove_file ~/Library/LaunchAgents/emacs-server.plist
    fi
	remove_dir $EMACS_CONF

fi
