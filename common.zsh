############################################################################
# Command-line stuff
############################################################################

OSSYS=`uname -s | tr '[:upper:]' '[:lower:]'`
OSDIST=
OSVERSION=`uname -r`
OSARCH=`uname -m`

decode_os_type() {
    case "$OSSYS" in
	darwin)
	    STDOUT=`defaults read loginwindow SystemVersionStampAsString`
	    if [[ $? -eq 0 ]] ; then
		OSSYS=macos
		OSVERSION=$STDOUT
	    fi
	    ;;
	linux)
	    # If available, use LSB to identify distribution
	    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
		OSDIST=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
	    else
		# Otherwise, use release info file
		OSDIST=$(ls -d /etc/[A-Za-z]*[_-](version|release) | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | grep -v system)
	    fi
	    ;;
	msys*)
	    OSSYS=windows
	    OSVERSION=`ver | cut - d [ -f 2 | cut -d ] -f 1 | cut -d ' ' -f 2`
	    ;;
	*)
	    log-error "Unknown OS $OSSYS unsupported"
	    ;;
    esac
    
    log-debug "OS=$OSSYS ($OSTYPE) DIST=$OSDIST VERSION=$OSVERSION ARCH=$OSARCH"
}

ACTION=install

parse_action() {
    case $1
    in
	-h)  echo_bright "NAME";
	     echo "\tsetup.zsh - setup environment, cross-platform";
	     echo_bright "SYNOPSIS";
	     echo "\tsetup.zsh [-v] [-i -u -l -h]";
	     echo_bright "DESCRIPTION";
             echo "\t-h\tshow help";
             echo "\t-i\trun all install actions (default)";
             echo "\t-l\tlink files only";
             echo "\t-u\tupgrade only actions";
             echo "\t-v\tverbose mode";
	     exit 0;;
	-i)  ACTION=install;;
	-u)  ACTION=update;;
	-l)  ACTION=link;;
	-v)  shift;
	     LOGLEVEL=3;
	     parse_action $1;;
	-V)  shift;
	     LOGLEVEL=4;
	     parse_action $1;;
	*)   ACTION=install;;
    esac
    log-info "Performing $ACTION on $OSSYS";
}

############################################################################
# Actions
############################################################################

os_customizations() {
    if [[ $OSSYS = macos && $ACTION = install ]] ; then
	log-debug "Writing common defaults"
	defaults write com.apple.dashboard devmode YES
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
	defaults write com.apple.Dock showhidden -bool YES
    fi
}

create_development_dir() {
    if [[ $OSSYS = macos ]] ; then
	export DEVHOME=$HOME/Projects
    else
	export DEVHOME=$HOME/development
    fi
    if [ ! -d "$DEVHOME" ] ; then
	mkdir $DEVHOME
    fi
}


install_package_manager() {
    # Note that right now we don't do anything with this, should
    # really adjust the package manager and some other actions.
    if [[ $OSSYS = linux ]] ; then
	STDOUT=`yum --version`
	if [[ $? -eq 0 ]] ; then
	    log-debug "You appear to be running a redhat derived Linux"
	    INSTALLER='sudo yum'
	    APP_INSTALLER=snap
	else
	    STDOUT=`apt-get --version`
	    if [[ $? -eq 0 ]] ; then
		INSTALLER='sudo apt-get'
		APP_INSTALLER=flatpack
	    else
		log-critical "No known installer (yum|apt-get) found"
	    fi
	fi
    fi
    if [[ $ACTION = install ]] ; then
	log-debug "installing homebrew package manager"
	if [[ $OSSYS = darwin ]] ; then
	    if [ ! -d "/usr/local/Homebrew" ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		brew tap 'homebrew/services'
		brew services
	    fi
	fi
	INSTALLER=brew
	APP_INSTALLER='brew cask'
    fi
    if [[ $ACTION = update ]] ; then
	log-debug "updating package manager"
	$INSTALLER $ACTION
	if [[ $OSSYS = linux ]] ; then
	    $INSTALLER list --upgradable
	fi
    fi
}

cleanup_packages() {
    if [[ $ACTION = update ]] ; then
	update_package_manager
	if [[ $OSSYS = macos ]] ; then
	    $INSTALLER cleanup
	    $INSTALLER doctor
	else
	    $INSTALLER autoremove
	fi
    fi
}

install_package_for() {
    if [[ $OSSYS = $1* && $ACTION = install ]] ; then
	shift
	install_package $@
    fi
}

install_package() {
    if [[ $ACTION = install ]] ; then
	if [[ "$1" = "-app" ]] ; then
	    shift
	    $APP_INSTALLER $ACTION $@
	else
	    $INSTALLER $ACTION $@
	fi
    fi
}

install_python() {
    if [[ $ACTION = install ]] ; then
	conda install --yes $@
    fi
}

install_racket() {
    if [[ $ACTION = install ]] ; then
	raco pkg install --deps search-auto $@
    fi
}

link_dot_file() {
    if [[ $ACTION = (install|update|link) ]] ; then
	STDOUT=`ln -s $DOTFILEDIR/$1 $2 2>&1`
	if [[ $? -ne 0 ]] ; then
	    log-warning $STDOUT
	fi
    fi
}

install_zsh() {
    if [[ $ACTION = install ]] ; then
	log-debug "++ zsh"
	install_package zsh zsh-completions
	local _shellloc=`which zsh`
	if [[ $(grep -q $_shelloc /etc/shells) -ne 0 ]] ; then
	    sudo cat /etc/shells | sed -e "\$a$_shellloc" >/etc/shells
	fi
	sudo chsh -s $_shellloc
    fi
    
    if [[ $ACTION = update ]] ; then
	update_package zsh
	upgrade_oh_my_zsh
    fi

    if [[ $ACTION = (install|update|link) ]] ; then
	log-debug "++ zsh dot files"
	link_dot_file dot-zshrc $HOME/.zshrc
	link_dot_file dot-zshenv $HOME/.zshenv
    fi
    
    if [[ $ACTION = install ]] ; then
	log-debug "++ oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	export ZSH=~/.oh-my-zsh
	
	log-debug "++ oh-my-zsh plugins"
	git clone https://github.com/bhilburn/powerlevel9k.git $ZSH/custom/themes/powerlevel9k
	git clone https://github.com/zsh-users/zsh-docker.git $ZSH/custom/plugins/zsh-docker
	
	log-debug "++ powerline fonts"
	if [[ $OSSYS = macos ]] ; then
	    install_package homebrew/cask-fonts/font-meslo-nerd-font
	    install_package homebrew/cask-fonts/font-meslo-nerd-font-mono
	else
	    install_package fonts-powerline
	fi
    fi
}

install_openssh_server() {
    if [[ $OSSYS = linux && $ACTION = install ]] ; then
	local SSHDCONF=/etc/ssh/sshd_config
	install_package linux openssh-server
	sudo mv $SSHDCONF $SSHDCONF.orig
	sudo cat $SSHDCONF.orig | sed 's/#Port 22/Port 1337/g' > $SSHDCONF
	sudo ufw allow 1337
	sudo service ssh restart
    fi
}

install_proton_vpn() {
    if [[ $OSSYS = linux && $ACTION = install ]] ; then
	if [[ "$1" = "" ]] ; then
	    _country=US
	else
	    _country = $1
	fi
	install_package_for linux openvpn network-manager-openvpn-gnome resolvconf
	curl -o ~/Downloads/protonvpn-$_country.ovpn "https://account.protonvpn.com/api/vpn/config?APIVersion=3&Country=$_country&Platform=Linux&Protocol=udp"
	# from https://protonvpn.com/support/linux-vpn-tool/
	curl -o ~/Downloads/protonvpn-cli.sh "https://raw.githubusercontent.com/ProtonVPN/protonvpn-cli/master/protonvpn-cli.sh"
	sudo zsh ~/Downloads/protonvpn-cli.sh --install
	log-debug "!! leaving ~/Downloads/protonvpn-$_country.ovpn and ~/Downloads/protonvpn-cli.sh"
    fi
}

install_docker() {
    if [[ $ACTION = install ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    curl -o ~/Downloads/Docker.dmg "https://download.docker.com/mac/stable/Docker.dmg"
	    open ~/Downloads/Docker.dmg
	    log-debug "!! leaving ~/Downloads/Docker.dmg"
	else
	    install_package apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	    update_package_manager
	    install_package docker-ce docker-ce-cli containerd.io
	    sudo groupadd docker
	    sudo usermod -aG docker $USER
	    if [ -e "$HOME/.docker" ] ; then
		sudo chown "$USER":"$USER" "$HOME/.docker" -R
		sudo chmod g+rwx "$HOME/.docker" -R
	    fi
	    sudo systemctl enable docker
	    echo_instruction "docker run hello-world"
	fi
    fi
}

install_nvidia_cuda() {
    if [[ $ACTION = install ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    log-warning "Unsupported under MacOS"
	else
	    log-debug "++ graphics drivers"
	    local NVVER=`nvidia-smi |grep Version |awk '{ print $6 }'`
	    if [ ! "$NVVER"  = "418.43" ]; then
		curl -o ~/Downloads/nvidia_linux.run "http://us.download.nvidia.com/XFree86/Linux-x86_64/418.43/NVIDIA-Linux-x86_64-418.43.run"
		sudo sh nvidia_linux.run
		log-debug "++ turning off Nouveau X drivers"
		sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
		sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
		log-debug "!! leaving ~/Downloads/nvidia_linux.run"
	    fi
	    echo_instruction "reboot now for driver update"
	    
	    log-debug "++ CUDA programming support..."
	    curl -o ~/Downloads/cuda_linux.run "https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run"
	    sudo sh cuda_linux.run
	    mkdir $DEVHOME/cuda
	    cuda-install-samples-10.1.sh $DEVHOME/development/cuda/
	    log-debug "!! leaving ~/Downloads/cuda_linux.run"
	fi
    fi
}
