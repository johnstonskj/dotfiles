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
install_zsh
install_openssh
install_docker
install_proton_vpn "US"

log-info "Development Environment..."
install_emacs
install_git

log-info "Programming languages (linux)..."
install_package_for linux gcc make racket anaconda
install_package_for linux -app vscode
install_package_for linux -app intellij-idea-community --classic

log-info "Programming languages (macos)..."
echo_instruction_for macos "xcode-select --install"
install_package_for macos kotlin minimal-racket
install_package_for macos -app anaconda
echo_instruction "ln -s /usr/local/anaconda3 $HOME/anaconda3"
install_package_for macos -app visual-studio-code intellij-idea-ce

log-info "Programming languages (shared)..."
install_rust
install_package -racket iracket
echo_instruction "racket -l iracket/install"

log-info "NVIDIA CUDA..."
install_nvidia_cuda

log-info "Machine Leaning..."
install_package -python pytorch torchvision -c pytorch
install_package_for linux -python cudatoolkit=10.0 

log-info "Desktop/Productivity Applications..."
install_package -app slack spotify
install_package_for linux -app cloudprint hangups
install_package_for macos -app iterm2 google-chrome wireshark tidal
install_tex

############################################################################
# non-Git delegated configuration
############################################################################

if [ -e "$DOTFILEDIR/work-setup.zsh" ] ; then
    log-info "Work related installs..."
    source "$DOTFILEDIR/work-setup.zsh"
fi
