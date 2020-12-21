install_package_for linux racket
install_package_for macos -app racket

install_package -racket iracket
run_command racket -l iracket/install

link_env_file racket