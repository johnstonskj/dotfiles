if [[ $ACTION = (install|update) ]] ; then
	install_package_for linux emacs-nox elpa-racket-mode
	install_package_for macos emacs markdown-mode rust-mode cargo-mode
	install_package_for macos -app font-linux-libertine
fi

if [[ $ACTION = (install|update|link) ]] ; then
    run_command mkdir -p $HOME/.emacs.d/lib
	link_dot_file $CURR_ACTION/init.el $HOME/.emacs.d/init.el
fi

if [[ $ACTION = (install|update) ]] ; then
	run_command curl -o $HOME/.emacs.d/lib/scribble.el "https://www.neilvandyke.org/scribble-emacs/scribble.el"
fi
