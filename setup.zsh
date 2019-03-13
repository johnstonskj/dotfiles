#! /usr/bin/env zsh

############################################################################
# Setup the process
############################################################################

DOTFILEDIR=${0:a:h}

source $DOTFILEDIR/logging.zsh
source $DOTFILEDIR/common.zsh

parse_action $*

############################################################################
# Top-level configuration
############################################################################

os_customizations

log-info "Setting up development directory..."
create_development_dir

log-info "Installing/Upating package manager..."
install_package_manager
update_package_manager

############################################################################
# Installation and configuration actions
############################################################################

log-info "System tools..."
install_package glances gpg htop lynx parallel tmux
link_dot_file dot-tmux.conf $HOME/.tmux.conf
if [ ! -d $HOME/.gnupg ] ; then
    log-info "++ GPG initialization..."
    gpg --list-keys
fi
install_package_for linux ethtool
install_package_for darwin gnu-sed

log-info "Emacs..."
install_package_for linux emacs-nox
install_package_for darwin emacs markdown-mode

log-info "OpenSSH server..."
install_openssh_server

log-info "Git"
install_package git git-lfs
link_dot_file dot-gitconfig $HOME/.gitconfig
link_dot_file dot-gitignore_global $HOME/.gitignore_global

log-info "Zshell..."
install_zsh

log-info "Programming languages..."
install_package_for linux gcc make
# echo exec: xcode-select --install
install_package_for darwin kotlin
install_package anaconda racket
install_package libzmq5
install_racket iracket
# racket -l iracket/install

log-info "Container runtime..."
install_docker

log-info "NVIDIA CUDA..."
install_nvidia_cuda

log-info "Machine Leaning..."
install_python pytorch torchvision cudatoolkit=10.0 -c pytorch

log-info "Random..."
install_package hangups
echo exec: hangups --manual-login
alias hangouts=hangups --col-scheme=solarized-dark

if [ -e "$DOTFILEDIR/work-setup.zsh" ] ; then
    log-info "Work related install"
    source "$DOTFILEDIR/work-setup.zsh"
fi
