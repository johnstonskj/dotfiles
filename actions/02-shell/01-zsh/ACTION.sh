if [[ $ACTION = (install|update|uninstall) ]] ; then
	log-debug "+++ installing zsh"
	install_package zsh zsh-completions
	install_package_for macos zsh-navigation-tools
fi

if [[ $ACTION = install ]] ; then
	log-debug "+++ integrating shell"
	local _shellloc=`which zsh`
	if [[ $(grep -q $_shellloc /etc/shells) -ne 0 ]] ; then
	    run_command sudo cat /etc/shells | sed -e "\$a$_shellloc" >/etc/shells
	fi
	run_command chsh -s $_shellloc
	run_command chmod go-w '/user/local/share'
fi
    
if [[ $ACTION = (install|update|uninstall|link) ]] ; then
	log-debug "+++ linking zsh dot files"
	# See https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout
	link_file dot-zshenv $HOME/.zshenv
	link_file dot-zshrc $HOME/.zshrc
	link_file dot-zlogin $HOME/.zlogin

	#link_dot_file $CURR_ACTION/dot-zprofile $HOME/.zprofile
	#link_dot_file $CURR_ACTION/dot-zlogout $HOME/.zlogout
fi
