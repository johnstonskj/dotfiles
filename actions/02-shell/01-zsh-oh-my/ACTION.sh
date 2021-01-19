if [[ $ACTION = install ]] ; then
    run_command curl -fsSL -o "$LOCAL_DOWNLOADS/oh-my-zsh-install.sh" "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
    run_command sh "$LOCAL_DOWNLOADS/oh-my-zsh-install.sh"
    remove_file "$LOCAL_DOWNLOADS/oh-my-zsh-install.sh"
    export ZSH=~/.oh-my-zsh

    run_command git clone "https://github.com/zsh-users/zsh-docker.git" "$ZSH/custom/plugins/zsh-docker"
fi
