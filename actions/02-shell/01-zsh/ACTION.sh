if [[ $ACTION = (install|update|uninstall) ]] ; then
	log-debug "+++ installing zsh"
	install_package zsh
fi

if [[ $ACTION = install ]] ; then
	log-debug "+++ integrating shell"
	local _shellloc=$(command -v zsh) >/dev/null 2>&1 || exit 1
	if [[ $(grep -q $_shellloc /etc/shells) -ne 0 ]] ; then
	    run_command sudo cat /etc/shells | sed -e "\$a$_shellloc" >/etc/shells
	fi
	run_command chsh -s $_shellloc
	run_command chmod go-w '/user/local/share'
fi

if [[ $ACTION = (install|update|uninstall|link) ]] ; then
	log-debug "+++ linking zsh dot files"
	link_file dot-zshenv $HOME/.zshenv
	link_file dot-zshrc $HOME/.zshrc
	link_file dot-zlogin $HOME/.zlogin
fi
