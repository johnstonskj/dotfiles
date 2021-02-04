install_package glances htop lynx parallel
install_package_for linux ethtool
install_package_for macos coreutils gnu-sed

install_package_for linux fd-find
install_package_for macos fd

link_file credback $LOCAL_BIN/ddcpimg
link_file ddcpimg $LOCAL_BIN/ddcpimg
link_file lcolor $LOCAL_BIN/lcolor
