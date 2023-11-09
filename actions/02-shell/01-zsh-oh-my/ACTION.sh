function install_omzsh_plugin {
    local plugin=$1
    run_command git clone "https://github.com/zsh-users/zsh-${plugin}.git" "${ZSH_CUSTOM}/plugins/zsh-${plugin}"
}


if [[ $ACTION = install ]] ; then

    run_command curl -fsSL -o "$LOCAL_DOWNLOADS/oh-my-zsh-install.sh" "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
    run_command sh "$LOCAL_DOWNLOADS/oh-my-zsh-install.sh"
    remove_file "$LOCAL_DOWNLOADS/oh-my-zsh-install.sh"

    export ZSH="${HOME}/.oh-my-zsh"
    export ZSH_CUSTOM="${ZSH}/custom"

    install_omzsh_plugin autosuggestions
    install_omzsh_plugin completions
    install_omzsh_plugin docker

fi
