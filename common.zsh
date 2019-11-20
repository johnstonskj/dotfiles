############################################################################
# Command-line stuff
############################################################################

OSSYS=`uname -s | tr '[:upper:]' '[:lower:]'`
OSDIST=
OSVERSION=`uname -r`
OSARCH=`uname -m`
INSTALLER=
APP_INSTALLER=
UPDATER=
DOWNLOADS=~/Downloads

check_not_sudo() {
    if [[ $UID == 0 || $EUID == 0 ]]; then
        log-critical "Cannot run as root, run with -h for options"
    fi
}

decode_os_type() {
    case $OSSYS in
	darwin)
 	    STDOUT=$(defaults read loginwindow SystemVersionStampAsString)
	    if [[ $? -eq 0 ]] ; then
		OSSYS=macos
		OSVERSION=$STDOUT
	    fi
	    ;;
	linux)
	    # If available, use LSB to identify distribution
	    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
		OSDIST=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr '[:upper:]' '[:lower:]')
	    else
		# Otherwise, use release info file
		OSDIST=$(ls -d /etc/[A-Za-z]*[_-](version|release) | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | grep -v system | tr '[:upper:]' '[:lower:]')
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

    if [[ $OSSYS = macos ]] ; then
	INSTALLER=brew
	APP_INSTALLER=(brew cask)
	UPDATER=upgrade
    elif [[ $OSSYS = linux ]] ; then
	STDOUT=$(yum --version 2>&1)
	if [[ $? -eq 0 ]] ; then
	    log-debug "You appear to be running a redhat derived Linux"
	    INSTALLER=(sudo yum --assumeyes)
	    APP_INSTALLER=flatpack
	else
	    STDOUT=$(apt --version 2>&1)
	    if [[ $? -eq 0 ]] ; then
		log-debug "You appear to be running a debian derived Linux"
		INSTALLER=(sudo apt --assume-yes)
		APP_INSTALLER=snap
		UPDATER=upgrade
	    else
		log-critical "No known installer (yum|apt-get) found"
	    fi
	fi
    fi

    if [ ! -d "$DOWNLOADS" ] ; then
	run_command mkdir $DOWNLOADS
    fi
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
             echo "\t-V\tvery verbose mode";
	     echo "\nDo not run this command in sudo mode, it will ask for passwords when it needs them"
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
    log-info "Performing $ACTION on $OSSYS ($OSTYPE), DIST=$OSDIST, VERSION=$OSVERSION, ARCH=$OSARCH"
    log-info "Using install=$INSTALLER, app=$APP_INSTALLER, update=$UPDATER"
    log-info "Downloading temp files to $DOWNLOADS"
    run_command mkdir -p $DOWNLOADS
}

############################################################################
# Wrappers
############################################################################

run_command() {
    log-debug "+++ +++ executing: ${(j. .)@}"
    errfile=$(mktemp)
    out=$($@ 2>|"$errfile" )
    err=$(< "$errfile")
    rm "$errfile"
   
    res=("${(@f)out}")
    for s in $res; do log-debug ">>> $s"; done
    res=("${(@f)err}")
    for s in $res; do log-warning ">>> $s"; done
}

############################################################################
# Actions
############################################################################

os_customizations() {
    if [[ $OSSYS = macos && $ACTION = install ]] ; then
	log-debug "+++ writing common defaults"
	run_command defaults write com.apple.dashboard devmode YES
	run_command defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
	run_command defaults write com.apple.Dock showhidden -bool YES
    fi
}

create_development_dir() {
    if [[ $OSSYS = macos ]] ; then
	export DEVHOME=$HOME/Projects
    else
	export DEVHOME=$HOME/development
    fi
    if [ ! -d "$DEVHOME" ] ; then
	run_command mkdir $DEVHOME
    fi
}

install_package_manager() {
    if [[ $ACTION = install ]] ; then
	log-debug "+++ installing homebrew package manager"
	if [[ $OSSYS = darwin ]] ; then
	    if [ ! -d "/usr/local/Homebrew" ]; then
 		run_command curl -fsSL -o $DOWNLOADS/brew-install.rb https://raw.githubusercontent.com/Homebrew/install/master/install
 		run_command /usr/bin/ruby $DOWNLOADS/brew-install.rb 
		log-debug "!!! leaving $DOWNLOADS/brew-install.rb"
		run_command brew tap 'homebrew/services'
		run_command brew services
	    fi
	fi
    fi
    if [[ $ACTION = update ]] ; then
	log-debug "+++ updating package managers"
	run_command $INSTALLER $ACTION
	log-debug "+++ running package manager cleanup actions"
	if [[ $OSSYS = macos ]] ; then
	    run_command $INSTALLER cleanup
	    # and maybe ... $INSTALLER doctor
	else
	    run_command $INSTALLER autoremove
	fi
    fi
}

update_package_manager() {
    local old=$ACTION
    ACTION=update
    install_package_manager
    ACTION=$old
}

install_package_for() {
    if [[ $OSSYS = $1* && $ACTION = install ]] ; then
	shift
	install_package $@
    fi
}

install_package() {
    if [[ $ACTION = (install|update) ]] ; then
	local _action=$ACTION
	if [[ $ACTION = update && $UPDATER != "" ]] ; then
	    _action=$UPDATER
	fi
	log-debug "+++ performing $_action for ${(j. .)@}"
	case $1
	in
	    -app)
		shift
		run_command $APP_INSTALLER $_action $@
		;;
	    -python)
		shift
		run_command conda $ACTION --yes $@
		;;
	    -racket)
		shift
		run_command raco pkg $ACTION --deps search-auto $@
		;;
	    *)
		run_command $INSTALLER $_action $@ ;;
	esac
    fi
}

link_dot_file() {
    if [[ $ACTION = (install|update|link) ]] ; then
	if [[ -e $1 ]] ; then
	    run_command ln -s $DOTFILEDIR/$1 $2
	else
	    log-warning "dot-file $1 doesn't exist"
	fi
	
    fi
}

install_xcode() {
    xcode-select --install
    sudo xcode-select --switch /Applications/Xcode.app
}

install_gpg() {
    if [[ $ACTION = (install|upgrade) ]] ; then
	install_package gpg
	if [ ! -d $HOME/.gnupg ] ; then
	    log-info "++ GPG initialization..."
	    run_command gpg --list-keys
	fi
    fi
}

install_zsh() {
    if [[ $ACTION = (install|update) ]] ; then
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
    
    if [[ $ACTION = (install|update|link) ]] ; then
	log-debug "+++ linking zsh dot files"
	# See https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout
	link_dot_file dot-zshenv $HOME/.zshenv
	link_dot_file dot-zprofile $HOME/.zprofile
	link_dot_file dot-zshrc $HOME/.zshrc
	link_dot_file dot-zlogin $HOME/.zlogin
	link_dot_file dot-zlogout $HOME/.zlogout
    fi
    
    if [[ $ACTION = install ]] ; then
	log-debug "+++ installing oh-my-zsh"
	run_command curl -fsSL -o $DOWNLOADS/oh-my-zsh-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
	run_command sh $DOWNLOADS/oh-my-zsh-install.sh
	log-debug "!!! leaving $DOWNLOADS/oh-my-zsh-install.sh"
	export ZSH=~/.oh-my-zsh
	
	log-debug "+++ adding oh-my-zsh plugins"
	run_command git clone https://github.com/bhilburn/powerlevel9k.git $ZSH/custom/themes/powerlevel9k
	run_command git clone https://github.com/zsh-users/zsh-docker.git $ZSH/custom/plugins/zsh-docker
    fi

    if [[ $ACTION = (install|update) ]] ; then
	log-debug "+++ adding powerline fonts"
	install_package_for macos -app homebrew/cask-fonts/font-meslo-nerd-font
	install_package_for macos -app homebrew/cask-fonts/font-meslo-nerd-font-mono
	install_package_for linux fonts-powerline
# git clone https://github.com/powerline/fonts.git --depth=1
# cd fonts
# ./install.sh
# cd ..
# rm -rf fonts
    fi
}

install_openssh() {
    if [[ $OSSYS = linux && $ACTION = (install|update) ]] ; then
	log-debug "+++ install openssh packages"
	local SSHDCONF=/etc/ssh/sshd_config
	install_package linux openssh-server
	if [[ $ACTION = install ]] ; then
	    log-debug "+++ setting openssh config"
	    run_command sudo mv $SSHDCONF $SSHDCONF.orig
	    run_command sudo cat $SSHDCONF.orig | sed 's/#Port 22/Port 1337/g' > $SSHDCONF
	    run_command sudo ufw allow 1337
	    run_command sudo service ssh restart
	fi
    fi
}

install_proton_vpn() {
    if [[ $OSSYS = linux && $ACTION = (install|update) ]] ; then
	log-debug "+++ install openvpn packages"
	install_package_for linux openvpn network-manager-openvpn-gnome resolvconf
	if [[ "$1" = "" ]] ; then
	    _country=US
	else
	    _country = $1
	fi
	log-debug "+++ retrieving Proton config for country=$_country"
	run_command curl -o $DOWNLOADS/protonvpn-$_country.ovpn "https://account.protonvpn.com/api/vpn/config?APIVersion=3&Country=$_country&Platform=Linux&Protocol=udp"
	# from https://protonvpn.com/support/linux-vpn-tool/
	run_command curl -o $DOWNLOADS/protonvpn-cli.sh "https://raw.githubusercontent.com/ProtonVPN/protonvpn-cli/master/protonvpn-cli.sh"
	run_command sudo zsh $DOWNLOADS/protonvpn-cli.sh --install
 	log-debug "!!! leaving $DOWNLOADS/protonvpn-$_country.ovpn and $DOWNLOADS/protonvpn-cli.sh"
    elif [[ $OSSYS = macos && $ACTION = (install|update) ]] ; then
	run_command curl -o $DOWNLOADS/protonvpn.dmg "https://protonvpn.com/download/ProtonVPN.dmg"
	open $DOWNLOADS/protonvpn.dmg
 	log-debug "!!! leaving $DOWNLOADS/protonvpn.dmg"
    fi
}

install_docker() {
    if [[ $ACTION = (install|update) ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    log-debug "+++ installing Docker desktop (from disk image)"
	    run_command curl -o $DOWNLOADS/Docker.dmg "https://download.docker.com/mac/stable/Docker.dmg"
	    run_command open $DOWNLOADS/Docker.dmg
	    log-debug "!!! leaving $DOWNLOADS/Docker.dmg"
	else
	    log-debug "+++ installing Docker CLI"
	    install_package apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	    if [[ $ACTION = install ]] ; then
		run_command curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		run_command sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
		update_package_manager
	    fi
	    install_package docker-ce docker-ce-cli containerd.io
	    if [[ $ACTION = install ]] ; then
		log-debug "+++ updating Docker permissions"
		run_command sudo groupadd docker
		run_command sudo usermod -aG docker $USER
		if [ -e "$HOME/.docker" ] ; then
		    run_command sudo chown "$USER":"$USER" "$HOME/.docker" -R
		    run_command sudo chmod g+rwx "$HOME/.docker" -R
		fi
		run_command sudo systemctl enable docker
	    fi
	fi
	log-debug "+++ pulling Docker images from $DOTFILEDIR/docker-images"
	while IFS= read -r line; do
	log-debug "+++ +++ docker image $line"
	    run_command docker pull $line
	done < "$DOTFILEDIR/docker-images"
    fi
    if [[ $ACTION = install ]] ; then
	echo_instruction "docker run hello-world"
    fi
}

install_rust() {
    if [[ $ACTION = install ]] ; then
        log-debug "+++ installing rustup"
        run_command curl  -sSf -o $DOWNLOADS/sh.rustup.rs https://sh.rustup.rs
	run_command sh $DOWNLOADS/sh.rustup.rs -y -v --no-modify-path
	log-debug "!!! leaving $DOWNLOADS/sh.rustup.rs"

	# This should be the default, but just in case...
	run_command rustup toolchain add stable

	log-debug "+++ installing crates"
	while IFS= read -r line; do
	log-debug "+++ +++ crate $line"
	    run_command cargo install $line
	done < "$DOTFILEDIR/rs-crates"

	log-debug "+++ installing components"
	while IFS= read -r line; do
	log-debug "+++ +++ component $line"
	    run_command rustup component add $line
	done < "$DOTFILEDIR/rs-components"
	echo_instruction export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

	log-debug "+++ installing racer"
	run_command rustup toolchain add nightly
	run_command cargo +nightly install racer

    fi
    if [[ $ACTION = update ]] ; then
	rustup update
    fi
    if [[ $ACTION = (install|update) ]] ; then
	install_package_for macos rustc-completion
    fi
}

install_emacs() {
    if [[ $ACTION = (install|update) ]] ; then
	install_package_for linux emacs-nox elpa-racket-mode
	install_package_for macos emacs markdown-mode rust-mode cargo-mode
	install_package_for macos -app font-linux-libertine
    fi
    if [[ $ACTION = (install|update|link) ]] ; then
    	run_command mkdir -p $HOME/.emacs.d/lib
	link_dot_file init.el $HOME/.emacs.d/init.el
    fi
    if [[ $ACTION = (install|update) ]] ; then
	run_command curl -o $HOME/.emacs.d/lib/scribble.el "https://www.neilvandyke.org/scribble-emacs/scribble.el"
    fi
}

install_git() {
    if [[ $ACTION = (install|update) ]] ; then
	install_package git git-lfs
	install_package_for linux git-hub
	# maybe one day - https://github.com/sickill/git-dude
    fi
    if [[ $ACTION = (install|update|link) ]] ; then
	link_dot_file dot-gitconfig $HOME/.gitconfig
	link_dot_file dot-gitignore_global $HOME/.gitignore_global
    fi
}

install_nvidia_cuda() {
    if [[ $ACTION = install ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    log-warning "CUDA unsupported under MacOS"
	else
	    log-debug "+++ graphics drivers"
	    local NVVER=`nvidia-smi |grep Version |awk '{ print $6 }'`
	    if [ $NVVER  != "418.43" ]; then
		run_command curl -o $DOWNLOADS/nvidia_linux.run "http://us.download.nvidia.com/XFree86/Linux-x86_64/418.43/NVIDIA-Linux-x86_64-418.43.run"
		run_command sudo sh nvidia_linux.run
		log-debug "+++ turning off Nouveau X drivers"
		run_command sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
		run_command sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
		log-debug "!!! leaving $DOWNLOADS/nvidia_linux.run"
	    fi
	    echo_instruction "reboot now for driver update"
	    
	    log-debug "+++ CUDA programming support..."
	    run_command curl -o $DOWNLOADS/cuda_linux.run "https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run"
	    run_command sudo sh $DOWNLOADS/cuda_linux.run
	    run_command mkdir -p $DEVHOME/cuda
	    run_command cuda-install-samples-10.1.sh $DEVHOME/development/cuda/
	    log-debug "!!! leaving $DOWNLOADS/cuda_linux.run"
	fi
    fi
}

install_tex() {
    if [[ $ACTION = (install|update) ]] ; then
	install_package_for macos -app mactex texpad
    fi
}
