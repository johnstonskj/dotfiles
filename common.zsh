LOGLEVEL=1

__log() {
    printf "%s %8d %8s [%s] %s\n"  `date "+%Y:%m:%dT%H:%M:%S%Z"` $$ `logname` $1 $2
}

log() {
    print $1 $2
    if [ $1 -ge $LOGLEVEL ] ; then
	case $1 in
	    0)
		__log "CRITICAL" $2
		exit 1
		;;
	    1)
		__log "ERROR" $2
		;;
	    2)
		__log "WARNING" $2
		;;
	    3)
		__log "INFO" $2
		;;
	    *)
		__log "DEBUG" $2
		;;
	esac
    fi
}

log-critical() { log 0 $@ }
log-error() { log 1 $@ }
log-warning() { log 2 $@ }
log-info() { log 3 $@ }
log-debug() { log 4 $@ }

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
    log-debug "installing package manager"
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	if [ ! -d "/usr/local/Homebrew" ]; then
	    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
    fi
}

update_package_manager() {
    log-debug "updating package manager"
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	brew update
    else
	sudo apt update
	apt list --upgradable
    fi
}

cleanup_packages() {
    update_package_manager
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	brew cleanup
	brew doctor
    else
	sudo apt autoremove
    fi
}

install_package_for() {
    if [[ $OSTYPE = $1* ]] ; then
	shift
	install_package $@
    fi
}

install_package() {
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	brew install $@
    else
	sudo apt install $@
    fi
}

update_package() {
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	brew upgrade $@
    else
	sudo apt upgrade $@
    fi
}

install_python() {
    conda install --yes $@
}

install_racket() {
    raco pkg install --deps search-auto $@
}

link_dot_file() {
    ln -s $DOTFILEDIR/$1 $2
}

install_zsh() {
    log-debug "++ zsh"
    install_package zsh
    sudo chsh -s `which zsh`
    link_dot_file dot-zshrc $HOME/.zshrc
    link_dot_file dot-zshenv $HOME/.zshenv
    
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
}

update_zsh() {
    update_package zsh
    upgrade_oh_my_zsh
}

install_openssh_server() {
    local SSHDCONF=/etc/ssh/sshd_config
    if [[ $OSTYPE = linux* ]] ; then
	install_package linux openssh-server
	sudo mv $SSHDCONF $SSHDCONF.orig
	sudo cat $SSHDCONF.orig | sed 's/#Port 22/Port 1337/g' > $SSHDCONF
	sudo ufw allow 1337
	sudo service ssh restart
    fi
}

install_vscode() {
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
        download="https://go.microsoft.com/fwlink?LinkID=620882"
    else
	download="https://go.microsoft.com/fwlink?LinkID=760868"
    fi
    cd ~/Downloads
    if [[ $OSTYPE = (darwin|freebsd)* ]] ; then
	curl -o ./vscode.zip -L $download
	unzip ./vscode.zip
	sudo mv "Visual Studio Code.app" /Applications
    else
	curl -o ./vscode.deb -L $download
	sudo apt install ./vscode.deb
	download="https://go.microsoft.com/fwlink?LinkID=760868"
    fi
    log-debug "!! leaving ~/Downloads/vscode.(deb|zip)"
}

install_nvidia_cuda() {
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
}
