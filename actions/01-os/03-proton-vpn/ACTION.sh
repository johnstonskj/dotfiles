if [[ $OSSYS = linux && $ACTION = (install|update) ]] ; then
	log-debug "+++ install openvpn packages"
	install_package_for linux openvpn network-manager-openvpn-gnome resolvconf
	if [[ "$1" = "" ]] ; then
	    _country=US
	else
	    _country = $1
	fi
	log-debug "+++ retrieving Proton config for country=$_country"
	run_command curl -o $LOCAL_DOWNLOADS/protonvpn-$_country.ovpn "https://account.protonvpn.com/api/vpn/config?APIVersion=3&Country=$_country&Platform=Linux&Protocol=udp"
	# from https://protonvpn.com/support/linux-vpn-tool/
	run_command curl -o $LOCAL_DOWNLOADS/protonvpn-cli.sh "https://raw.githubusercontent.com/ProtonVPN/protonvpn-cli/master/protonvpn-cli.sh"
	run_command sudo zsh $LOCAL_DOWNLOADS/protonvpn-cli.sh --install
 	remove_file $LOCAL_DOWNLOADS/protonvpn-$_country.ovpn
 	remove_file $LOCAL_DOWNLOADS/protonvpn-cli.sh

elif [[ $OSSYS = macos && $ACTION = (install|update) ]] ; then
	run_command curl -o $LOCAL_DOWNLOADS/protonvpn.dmg "https://protonvpn.com/download/ProtonVPN.dmg"
	open $LOCAL_DOWNLOADS/protonvpn.dmg
 	log-debug "!!! leaving $LOCAL_DOWNLOADS/protonvpn.dmg"
fi
