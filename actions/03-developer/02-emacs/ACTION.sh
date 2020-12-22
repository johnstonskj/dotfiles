EMACS_CONF=$HOME/.emacs.d

if [[ $ACTION = (install|update) ]] ; then
	install_package_for linux emacs-nox elpa-racket-mode
	install_package_for macos emacs markdown-mode rust-mode cargo-mode
	install_package_for macos -app font-linux-libertine
fi

if [[ $ACTION = (install|update|link) ]] ; then
    make_dir $EMACS_CONF/lib
	link_file init.el $EMACS_CONF/init.el

	run_command curl -o $EMACS_CONF/lib/scribble.el "https://www.neilvandyke.org/scribble-emacs/scribble.el"
fi
