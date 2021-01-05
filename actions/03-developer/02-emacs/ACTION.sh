EMACS_CONF=$HOME/.emacs.d

install_package_for linux emacs-nox elpa-racket-mode
install_package_for macos emacs
install_package_for macos -app font-linux-libertine

link_env_file emacs

if [[ $ACTION = (install|update|link) ]] ; then
    make_dir $EMACS_CONF/lib
	link_file init.el $EMACS_CONF/init.el
	run_command curl -o $EMACS_CONF/lib/scribble.el "https://www.neilvandyke.org/scribble-emacs/scribble.el"
elif [[ $ACTION = uninstall ]] ; then
	remove_file $EMACS_CONF/lib/scribble.el
	remove_file $EMACS_CONF/init.el
	remove_dir $EMACS_CONF
fi
