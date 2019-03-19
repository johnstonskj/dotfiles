#! /usr/bin/env zsh

############################################################################
# Setup the process
############################################################################

DOTFILEDIR=${0:a:h}

source $DOTFILEDIR/logging.zsh
source $DOTFILEDIR/common.zsh

decode_os_type

parse_action $*

############################################################################
# Top-level configuration
############################################################################

os_customizations

log-info "Setting up development directory..."
create_development_dir

log-info "Installing/Upating package manager..."
install_package_manager

############################################################################
# Installation and configuration actions
############################################################################

log-info "System tools..."
install_package glances htop lynx parallel tmux
link_dot_file dot-tmux.conf $HOME/.tmux.conf
install_package_for linux ethtool
install_package_for macos gnu-sed
install_gpg

log-info "Emacs..."
install_package_for linux emacs-nox
install_package_for macos emacs markdown-mode

log-info "OpenSSH..."
install_openssh

log-info "Git"
install_package git git-lfs
link_dot_file dot-gitconfig $HOME/.gitconfig
link_dot_file dot-gitignore_global $HOME/.gitignore_global
install_package_for linux hub

log-info "Zshell..."
install_zsh

log-info "Programming languages (linux)..."
install_package_for linux gcc make racket
install_package_for linux rustc rust-doc rust-gdb rust-lldb
install_package_for linux anaconda 
install_package_for linux libzmq5
install_package_for linux -app vscode

log-info "Programming languages (macos)..."
echo_instruction_for macos "xcode-select --install"
install_package_for macos kotlin minimal-racket
install_package_for macos rust rustup-init rust-completion
install_package_for macos -app anaconda
echo_instruction "ln -s /usr/local/anaconda3 $HOME/anaconda3"

install_package_for macos zeromq
install_package_for macos -app visual-studio-code

log-info "Programming languages (shared)..."
install_package -racket iracket
echo_instruction "racket -l iracket/install"

log-info "Docker runtime..."
install_docker

log-info "NVIDIA CUDA..."
install_nvidia_cuda

log-info "Machine Leaning..."
install_package -python pytorch torchvision -c pytorch
install_package_for linux -python cudatoolkit=10.0 

log-info "Proton VPN..."
install_proton_vpn "US"

log-info "Random Applications..."
install_package_for linux -app cloudprint gitkracken hangups slack
install_package_for macos -app iterm2 google-chrome github

############################################################################
# non-Git delegated configuration
############################################################################

if [ -e "$DOTFILEDIR/work-setup.zsh" ] ; then
    log-info "Work related installs..."
    source "$DOTFILEDIR/work-setup.zsh"
fi
