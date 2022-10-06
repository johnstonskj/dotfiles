if [[ $ACTION = install ]] ; then
    log-debug "+++ installing rustup"
    run_command curl  -sSf -o "$LOCAL_DOWNLOADS/sh.rustup.rs" https://sh.rustup.rs
	run_command sh "$LOCAL_DOWNLOADS/sh.rustup.rs" -y -v --no-modify-path
	remove_file "$LOCAL_DOWNLOADS/sh.rustup.rs"
	run_command source "$HOME/.cargo/env"

	# This should be the default, but just in case...
	run_command rustup toolchain add stable

	log-debug "+++ installing crates"
	while IFS= read -r line; do
		log-debug "+++ +++ crate $line"
	    run_command cargo install $line
	done < "$CURR_ACTION/rs-crates"

	log-debug "+++ installing components"
	while IFS= read -r line; do
		log-debug "+++ +++ component $line"
	    run_command rustup component add $line
	done < "$CURR_ACTION/rs-components"
fi

if [[ $ACTION = update ]] ; then
	rustup update
fi

install_package_for macos rust-analyzer
install_package_for macos rustc-completion

link_env_file rust

link_env_file rtools

link_file cargo-publish $LOCAL_BIN/cargo-publish
link_file cargo-verify $LOCAL_BIN/cargo-verify
link_file rust-update $LOCAL_BIN/rust-update
