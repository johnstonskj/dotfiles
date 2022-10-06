install_package vim

link_file dot-vimrc $HOME/.vimrc

VIM_HOME=$HOME/.vim

make_dir $VIM_HOME/colors
link_file solarized.vim $VIM_HOME/colors/solarized.vim

run_command curl -fLo $VIM_HOME/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

link_env_file vim
