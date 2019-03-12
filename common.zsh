LOGLEVEL=1

echo $TERM | grep -q color
if [[ $? -ne 0 ]]; then
    COLOR=true;
else
    COLOR=false;
fi

colored() {
    local _color _string
    if [[ $COLOR -eq "true" ]]; then
	case $1 in
	    # Plain colors
	    "black")
		_color="0;30";;
	    "red")
		_color="0;31";;
	    "green")
		_color="0;32";;
	    "brown")
		_color="0;33";;
	    "blue")
		_color="0;34";;
	    "purple")
		_color="0;35";;
	    "cyan")
		_color="0;36";;
	    "light-gray")
		_color="0;37";;
	    # Bold colors
	    "dark-gray")
		_color="1;30";;
	    "light-red")
		_color="1;31";;
	    "light-green")
		_color="1;32";;
	    "yellow")
		_color="1;33";;
	    "light-blue")
		_color="1;34";;
	    "light-purple")
		_color="1;35";;
	    "light-cyan")
		_color="1;36";;
	    "white")
		_color="1;37";;
	    *)
		_color="0;37";;
	esac
	printf -v _string "\033[%sm%s\033[0m" $_color $2;
    else
	_string=$2;
    fi
    echo "$_string"
}

__log() {
    printf "%s %8d %8s [%s] - "  `date "+%Y:%m:%dT%H:%M:%S%Z"` $$ `logname` $1
    echo $(colored "white" $2)
}

log() {
    if [ $1 -le $LOGLEVEL ] ; then
	case $1 in
	    0)
		__log $(colored "light-red" "CRITICAL") $2;
		exit 1
		;;
	    1)
		__log $(colored "red" "ERROR") $2
		;;
	    2)
		__log $(colored "cyan" "WARNING") $2
		;;
	    3)
		__log $(colored "green" "INFO") $2
		;;
	    *)
		__log $(colored "light-gray" "DEBUG") $2
		;;
	esac
    fi
}

log-critical() { log 0 $@ }
log-error() { log 1 $@ }
log-warning() { log 2 $@ }
log-info() { log 3 $@ }
log-debug() { log 4 $@ }

echo_bright() {
    echo $(colored "white" $1)
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
             echo "\t-i\trun all install actions";
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
    log-info "Performing $ACTION on $OSTYPE";
}

os_customizations() {
    if [[ $OSTYPE = (darwin|freebsd)* && $ACTION = (install) ]] ; then
	defaults write com.apple.dashboard devmode YES
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
	defaults write com.apple.Dock showhidden -bool YES
    fi
}

create_development_dir() {
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
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
    if [[ $OSTYPE = linux* ]] ; then
	if [[ $(grep -q "Red Hat" /proc/version) -eq 0 ]] ; then
	    log-info "OS Appears to be Red Hat flavored"
	    LX_FLAVOR=redhat
	else
	    log-info "OS Appears to be Ubuntu flavored"
	    LX_FLAVOR=ubuntu
	fi
    fi
    if [[ $ACTION = (install) ]] ; then
	log-debug "installing package manager"
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    if [ ! -d "/usr/local/Homebrew" ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	    fi
	fi
    fi
}

update_package_manager() {
    if [[ $ACTION = (install|update) ]] ; then
	log-debug "updating package manager"
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    brew update
	else
	    sudo apt update
	    apt list --upgradable
	fi
    fi
}

cleanup_packages() {
    if [[ $ACTION = (update) ]] ; then
	update_package_manager
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    brew cleanup
	    brew doctor
	else
	    sudo apt autoremove
	fi
    fi
}

install_package_for() {
    if [[ $OSTYPE = $1* && $ACTION = (install) ]] ; then
	shift
	install_package $@
    fi
}

install_package() {
    if [[ $ACTION = (install) ]] ; then
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    brew install $@
	else
	    sudo apt install $@
	fi
    fi
}

update_package() {
    if [[ $ACTION = (install) ]] ; then
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    brew upgrade $@
	else
	    sudo apt upgrade $@
	fi
    fi
}

install_python() {
    if [[ $ACTION = (install) ]] ; then
	conda install --yes $@
    fi
}

install_racket() {
    if [[ $ACTION = (install) ]] ; then
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
    if [[ $ACTION = (install) ]] ; then
	log-debug "++ zsh"
	install_package zsh
	sudo chsh -s `which zsh`
    fi
    
    if [[ $ACTION = (install|update|link) ]] ; then
	log-debug "++ zsh dot files"
	link_dot_file dot-zshrc $HOME/.zshrc
	link_dot_file dot-zshenv $HOME/.zshenv
    fi
    
    if [[ $ACTION = (install) ]] ; then
	log-debug "++ oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	export ZSH=~/.oh-my-zsh
	
	log-debug "++ oh-my-zsh plugins"
	git clone https://github.com/bhilburn/powerlevel9k.git $ZSH/custom/themes/powerlevel9k
	git clone https://github.com/zsh-users/zsh-docker.git $ZSH/custom/plugins/zsh-docker
	
	log-debug "++ powerline fonts"
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    install_package homebrew/cask-fonts/font-meslo-nerd-font
	    install_package homebrew/cask-fonts/font-meslo-nerd-font-mono
	else
	    install_package fonts-powerline
	fi
    fi
}

update_zsh() {
    if [[ $ACTION = (update) ]] ; then
	update_package zsh
	upgrade_oh_my_zsh
    fi
}

install_openssh_server() {
    if [[ $OSTYPE = linux* && $ACTION = (install) ]] ; then
	local SSHDCONF=/etc/ssh/sshd_config
	install_package linux openssh-server
	sudo mv $SSHDCONF $SSHDCONF.orig
	sudo cat $SSHDCONF.orig | sed 's/#Port 22/Port 1337/g' > $SSHDCONF
	sudo ufw allow 1337
	sudo service ssh restart
    fi
}

install_vscode() {
    if [[ $ACTION = (install) ]] ; then
	local linkid
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
            download="https://go.microsoft.com/fwlink?LinkID=620882"
	else
	    download="https://go.microsoft.com/fwlink?LinkID=760868"
	fi
	cd ~/Downloads
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    curl -o ./vscode.zip -L "https://go.microsoft.com/fwlink?LinkID=$linkid"
	    unzip ./vscode.zip
	    sudo mv "Visual Studio Code.app" /Applications
	else
	    curl -o ./vscode.deb -L "https://go.microsoft.com/fwlink?LinkID=$linkid"
	    sudo apt install ./vscode.deb
	    download="https://go.microsoft.com/fwlink?LinkID=760868"
	fi
	log-debug "!! leaving ~/Downloads/vscode.(deb|zip)"
    fi
}

install_docker() {
    if [[ $ACTION = (install) ]] ; then
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    curl -o ~/Downloads/Docker.dmg "https://download.docker.com/mac/stable/Docker.dmg"
	    open ~/Downloads/Docker.dmg
	    log-debug "!! leaving ~/Downloads/Docker.dmg"
	else
	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	    sudo add-apt-repository \
		 "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	        		    $(lsb_release -cs) \
			    	 st able"
	    sudo apt-get update
	    sudo apt-get install docker-ce docker-ce-cli containerd.io
	fi
    fi
}

install_nvidia_cuda() {
    if [[ $ACTION = (install) ]] ; then
	if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	    log-warning "Unsupported under MacOS"
	else
	    log-debug "++ graphics drivers"
	    local NVVER=`nvidia-smi |grep Version |awk '{ print $6 }'`
	    if [ ! "$NVVER"  = "418.43" ]; then
		curl -o ~/Downloads/NVIDIA-Linux-x86_64-418.43.run "http://us.download.nvidia.com/XFree86/Linux-x86_64/418.43/NVIDIA-Linux-x86_64-418.43.run"
		sudo sh NVIDIA-Linux-x86_64-418.43.run
		log-debug "++ turning off Nouveau X drivers"
		sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
		sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
		log-debug "!! leaving ~/Downloads/NVIDIA-Linux-x86_64-418.43.run"
	    fi
	    log-info "++ reboot now for driver update"
	    
	    log-debug "++ CUDA programming support..."
	    curl -o ~/Downloads/cuda_10.1.105_418.39_linux.run "https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run"
	    sudo sh cuda_10.1.105_418.39_linux.run
	    mkdir $DEVHOME/cuda
	    cuda-install-samples-10.1.sh $DEVHOME/development/cuda/
	    log-debug "!! leaving ~/Downloads/NVIDIA-Linux-x86_64-418.43.run"
	fi
    fi
}
