#! /usr/bin/env zsh

export DOTFILES=${0:a:h}
export DEVHOME=~/development

if [ ! -d "$DEVHOME" ] ; then
    mkdir $DEVHOME
fi

echo Update packages...
sudo apt update
apt list --upgradable

# ********** tools **********
echo System tools...
sudo apt install tmux glances emacs-nox
# https://github.com/tmuxinator/tmuxinator
sudo apt install tmuxinator

# ********** tools **********
sudo apt install git
ln -s $DOTFILES/dot-gitconfig ~/.gitconfig
ln -s $DOTFILES/dot-gitignore_global ~/.gitignore_global

# ********** zsh **********
echo zsh...
sudo apt-get install zsh autojump fonts-powerline
sudo chsh -s `which zsh`
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
export ZSH=~/.oh-my-zsh
git clone https://github.com/bhilburn/powerlevel9k.git $ZSH/custom/themes/powerlevel9k
ln -s ~/.devenv/dot-zshrc ~/.zshrc

cd $DEVHOME
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts.git
./install.sh --copy --install-to-user-path --otf --complete

# ********** languages **********
echo Programming languages...
sudo apt install gcc racket
sudo apt install anaconda

# ********** cuda **********
echo NVIDIA CUDA...
nvidia-smi |grep Version
NVVER=`nvidia-smi |grep Version |awk '{ print $6 }'`
if [ ! "$NVVER"  = "418.43" ]; then
    curl -o ~/Downloads/NVIDIA-Linux-x86_64-418.43.run "http://us.download.nvidia.com/XFree86/Linux-x86_64/418.43/NVIDIA-Linux-x86_64-418.43.run"
    sudo sh NVIDIA-Linux-x86_64-418.43.run
    sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
fi
echo (reboot now for driver update)

echo CUDA Programming support...
curl -o ~/Downloads/cuda_10.1.105_418.39_linux.run "https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run"
sudo sh cuda_10.1.105_418.39_linux.run
mkdir /media/simon/development/cuda
cuda-install-samples-10.1.sh /media/simon/development/cuda/

conda install pytorch torchvision cudatoolkit=10.0 -c pytorch
