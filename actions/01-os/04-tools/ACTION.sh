install_package htop parallel jq

install_package_for linux ethtool
install_package_for linux fd-find

install_package_for macos coreutils gnu-sed
install_package_for macos fd fzf telnet

link_file credback $LOCAL_BIN/credback
link_file ddcpimg $LOCAL_BIN/ddcpimg
link_file lcolor $LOCAL_BIN/lcolor
link_file nasync $LOCAL_BIN/nasync

link_env_file tools
