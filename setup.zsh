#! /usr/bin/env zsh

DOTFILEDIR=${0:a:h}

source $DOTFILEDIR/common.zsh

parse_action $*

os_customizations

create_development_dir

install_package_manager
update_package_manager

log-info "System tools..."
install_package parallel htop glances tmux
link_dot_file dot-tmux.conf $HOME/.tmux.conf
install_package_for linux ethtool
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
install_package_for linux gcc
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
